require 'spec_helper'

describe UsersController do
  before do
    fake_admin_login
    fake_session = Session.new()
    fake_session.stub(:admin?).with(no_args()).and_return(true)
    Session.stub(:get).and_return(fake_session)
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  describe "GET index" do
    before :each do
      @user = mock_user({:merge=>{},:user_name=>"someone"})
      User.stub!(:view).and_return([@user])
    end

    it "assigns all users as @users" do
      get :index
      assigns[:users].should == [@user]
    end

    it "assigns users_details for backbone" do
      get :index
      users_details = assigns[:users_details]
      users_details.should_not == nil
      user_detail = users_details[0]
      user_detail[:user_name].should == "someone"
      user_detail[:user_url].should_not be_blank
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      User.stub!(:get).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
    end

    it "should flash an error and go to listing page if the resource is not found" do
      User.stub!(:get).with("invalid record").and_return(nil)
      get :show, :id=> "invalid record"
      flash[:error].should == "User with the given id is not found"
      response.should redirect_to(:action => :index)
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      User.stub!(:new).and_return(mock_user)
      get :new
      assigns[:user].should equal(mock_user)
    end

    it "should assign all the available roles as @roles" do
      roles = ["roles"]
      Role.stub!(:all).and_return(roles)
      get :new
      assigns[:roles].should == roles
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      Role.stub!(:all).and_return(["roles"])
      User.stub!(:get).with("37").and_return(mock_user(:full_name => "Test Name"))
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
      assigns[:roles].should == ["roles"]
    end
  end


  describe "DELETE destroy" do
    it "destroys the requested user" do
      User.should_receive(:get).with("37").and_return(mock_user)
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the users list" do
      User.stub!(:get).and_return(mock_user(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(users_url)
    end
  end

  describe "GET index" do
    it "should not show any users in index (Forbidden) for non-admin" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      Session.stub(:get).and_return(fake_session)
      User.stub!(:view).and_return([mock_user])
      get :index
      assigns[:users].should == nil
    end
  end

  describe "GET show" do
    it "should show self user for non-admin" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      Session.stub(:get).and_return(fake_session)

      User.stub!(:get).with("24").and_return(mock_user)
      mock_user.should_receive(:user_name).with(no_args()).and_return('self')
      get :show, :id => "24"
      assigns[:user].should_not == nil
    end
    it "should not show non-self user for non-admin" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      fake_session.stub(:user_name).with(no_args()).and_return('me')
      Session.stub(:get).and_return(fake_session)
      User.stub!(:get).with("37").and_return(mock_user)
      mock_user.should_receive(:user_name).with(no_args()).and_return('not-self')
      controller.should_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :show, :id => "37"
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      Session.stub(:get).and_return(fake_session)

      User.stub!(:new).and_return(mock_user)
      get :new
      assigns[:user].should equal(nil)
    end
  end

  describe "GET edit" do
    it "should not allow editing a non-self user for non-admin" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      fake_session.stub(:user_name).and_return('me')
      Session.stub(:get).and_return(fake_session)
      User.stub!(:get).with("37").and_return(mock_user(:full_name => "Test Name"))
      mock_user.should_receive(:user_name).with(no_args()).and_return('not-self')
      controller.should_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :edit, :id => "37"
    end
    it "should allow editing a non-self user for non-admin" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      fake_session.stub(:user_name).and_return('fakeuser')
      Session.stub(:get).and_return(fake_session)
      User.stub!(:get).with("24").and_return(mock_user(:full_name => "Test Name"))
      mock_user.should_receive(:user_name).with(no_args()).and_return('fakeuser')
      controller.should_not_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :edit, :id => "24"
    end

  end


  describe "DELETE destroy" do
    it "should not allow a destroy" do
      fake_login
      fake_session = Session.new()
      fake_session.stub(:admin?).with(no_args()).and_return(false)
      Session.stub(:get).and_return(fake_session)

      User.should_not_receive(:get).with("37").and_return(mock_user)
      mock_user.should_not_receive(:destroy)
      delete :destroy, :id => "37"
    end

  end
  describe "POST update" do
    let(:mock_user) { User.new }
    before :each do
        fake_login
        @fake_session = Session.new
        controller.stub(:app_session).and_return(@fake_session)
        mock_user.stub(:update_attributes).and_return(true)
        User.stub(:get).with("24").and_return(mock_user)
    end

    it "should clean the params for role_names" do
      @fake_session.stub(:admin?).and_return(true)
      mock_user.should_receive(:update_attributes).with({"role_names"=>["some_name"]}).and_return(true)
      post :update, {:id => "24", :user => {:role_names => ["", "some_name"]}}
    end

    context "when not admin user" do
      before :each do
        @fake_session.stub(:admin?).and_return(false)
      end
      it "should not allow to edit admin specific fields" do
        controller.stub(:current_user_name).and_return("test_user")
        mock_user.stub(:user_assignable?).and_return(false)
        controller.should_receive(:handle_authorization_failure)
        post :update, { :id => "24", :user => {:user_type => "Administrator"  } }
      end
    end
    context "when admin user" do

      before :each do
        @fake_session.stub(:admin?).and_return(true)
      end

      it "should allow to edit admin specific fields" do
        controller.stub(:app_session).and_return(@fake_session)
        User.stub(:get).with("24").and_return(mock_user)
        controller.should_not_receive(:handle_authorization_failure)
        post :update, { :id => "24", :user => {:user_type => "Administrator"  } }
      end

      it "should render edit page and assign roles if validation fails" do
        controller.stub(:app_session).and_return(@fake_session)
        Role.stub(:all).and_return(["roles"])
        User.stub(:get).with("24").and_return(mock_user)
        mock_user.should_receive(:update_attributes).and_return(false)
        post :update, { :id => "24", :user => {:user_type => "Administrator"  } }
        assigns[:roles].should == ["roles"]
      end
    end

    context "create a user" do
      before :each do
        fake_admin_login
      end

      it "should create admin user if the admin user type is specified" do
        User.should_receive(:new).with({"role_names"=>["Adminstrator"]}).and_return(mock_user)
        mock_user.should_receive(:save).and_return(true)
        post :create, {"user" => {"role_names" => ["Adminstrator"]}}
      end

      it "should clean the role_names params" do
        User.should_receive(:new).with({ "role_names" => ["some_name"]}).and_return(mock_user)
        mock_user.stub(:save).and_return(true)
        put :create, {:user => {:role_names => ["", "", "some_name"]}}
      end

      it "should render new if the given user is invalid and assign user,roles" do
        Role.stub(:all).and_return("some roles")
        User.should_receive(:new).and_return(mock_user)
        mock_user.should_receive(:save).and_return(false)
        put :create, {:user => {:role_names => ["Administrator"]}}
        response.should render_template :new
        assigns[:user].should == mock_user
        assigns[:roles].should == "some roles"
      end
    end
  end
end
