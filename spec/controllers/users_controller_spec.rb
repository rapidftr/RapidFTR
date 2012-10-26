require 'spec_helper'

describe UsersController do
  before do
    fake_admin_login
    fake_session = Session.new()
    fake_session.stub(:admin?).with(no_args()).and_return(true)
    Session.stub(:get).and_return(fake_session)
  end

  def fake_view_user_login
    user = User.new(:user_name => 'fakelimited')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::USERS[:view]])])
    fake_login user
  end

  def fake_create_edit_user_login
    user = User.new(:user_name => 'fakelimited')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::USERS[:create_and_edit]])])
    fake_login user
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  describe "GET index" do
    it "assigns all users as @users" do
      @user = mock_user({:merge => {}, :user_name => "someone"})
      User.stub!(:view).and_return([@user])
      get :index
      assigns[:users].should == [@user]
    end

    it "assigns users_details for backbone" do
      @user = mock_user({:merge => {}, :user_name => "someone"})
      User.stub!(:view).and_return([@user])
      get :index
      users_details = assigns[:users_details]
      users_details.should_not == nil
      user_detail = users_details[0]
      user_detail[:user_name].should == "someone"
      user_detail[:user_url].should_not be_blank
    end

    it "should throw exception if user is not authorized" do
      fake_login
      fake_session = Session.new()
      Session.stub(:get).and_return(fake_session)
      mock_user = mock_user({:merge => {}, :user_name => "someone"})
      User.stub!(:view).and_return([mock_user])
      controller.should_receive(:handle_authorization_failure).with(anything)
      get :index
    end

    it "should authorize index page for read only users" do
      user = User.new(:user_name => 'view_user')
      user.stub!(:roles).and_return([Role.new(:permissions => [Permission::USERS[:view]])])
      fake_login user
      controller.should_not_receive(:handle_authorization_failure).with(anything)
      get :index
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      mock_user = mock(:user_name => "UserName")
      User.stub!(:get).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
    end

    it "should flash an error and go to listing page if the resource is not found" do
      User.stub!(:get).with("invalid record").and_return(nil)
      get :show, :id => "invalid record"
      flash[:error].should == "User with the given id is not found"
      response.should redirect_to(:action => :index)
    end

    it "should show self user for non-admin" do
      fake_login
      mock_user = mock({:user_name => 'fakeuser'})
      User.stub!(:get).with("24").and_return(mock_user)
      controller.should_not_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :show, :id => "24"
      assigns[:user].should_not == nil
    end

    it "should not show non-self user for non-admin" do
      fake_login
      mock_user = mock({:user_name => 'some_random'})
      User.stub!(:get).with("37").and_return(mock_user)
      controller.should_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :show, :id => "37"
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

    it "should throw error if an user without authorization tries to access" do
      fake_view_user_login
      controller.should_receive(:handle_authorization_failure).with(anything)
      get :new
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      Role.stub!(:all).and_return(["roles"])
      mock_user = mock(:user_name => "Test Name", :full_name => "Test")
      User.stub!(:get).with("37").and_return(mock_user)
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
      assigns[:roles].should == ["roles"]
    end

    it "should not allow editing a non-self user for users without access" do
      fake_view_user_login
      User.stub!(:get).with("37").and_return(mock_user(:full_name => "Test Name"))
      mock_user.should_receive(:user_name).with(no_args()).and_return('not-self')
      controller.should_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :edit, :id => "37"
    end

    it "should allow editing a non-self user for user having edit permission" do
      fake_create_edit_user_login
      mock_user = mock(:full_name => "Test Name", :user_name => 'fakeuser')
      User.stub!(:get).with("24").and_return(mock_user)
      controller.should_not_receive(:handle_authorization_failure).with(anything).and_return(anything)
      get :edit, :id => "24"
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
    context "when not admin user" do
      it "should not allow to edit admin specific fields" do
        fake_login
        mock_user = mock({:user_name => "User_name"})
        User.stub(:get).with("24").and_return(mock_user)
        controller.stub(:current_user_name).and_return("test_user")
        mock_user.stub(:user_assignable?).and_return(false)
        controller.should_receive(:handle_authorization_failure)
        post :update, {:id => "24", :user => {:user_type => "Administrator"}}
      end
    end

    context "when admin user" do
      it "should allow to edit admin specific fields" do
        fake_create_edit_user_login
        mock_user = mock({:user_name => "Some_name"})
        mock_user.should_receive(:update_attributes).with({"user_type" => "Administrator"})
        User.stub(:get).with("24").and_return(mock_user)
        controller.should_not_receive(:handle_authorization_failure)
        post :update, {:id => "24", :user => {:user_type => "Administrator"}}
      end

      it "should render edit page and assign roles if validation fails" do
        fake_create_edit_user_login
        Role.stub(:all).and_return(["roles"])
        mock_user = mock({:user_name => "Some_name"})
        User.stub(:get).with("24").and_return(mock_user)
        mock_user.should_receive(:update_attributes).and_return(false)
        post :update, {:id => "24", :user => {:user_type => "Administrator"}}
        assigns[:roles].should == ["roles"]
      end
    end
    context "create a user" do
      it "should create admin user if the admin user type is specified" do
        fake_create_edit_user_login
        mock_user = User.new
        User.should_receive(:new).with({"role_names" => %w(Administrator)}).and_return(mock_user)
        mock_user.should_receive(:save).and_return(true)
        post :create, {"user" => {"role_names" => %w(Administrator)}}
      end

      it "should render new if the given user is invalid and assign user,roles" do
        mock_user = User.new
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
