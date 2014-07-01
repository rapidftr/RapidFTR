require 'spec_helper'

describe UsersController do
  before do
    fake_admin_login
    fake_session = Session.new()
    fake_session.stub(:admin?).with(no_args()).and_return(true)
    Session.stub(:get).and_return(fake_session)
  end

  def mock_user(stubs={})
    @mock_user ||= stub_model(User, stubs)
  end

  describe "GET index" do
    before do
      @user = mock_user({:merge => {}, :user_name => "someone"})
    end

    it "shows the page name" do
      get :index
      assigns[:page_name].should == "Manage Users"
    end

    context "filter and sort users" do
       before do
         @active_user_one = mock_user({:merge => {}, :user_name => "active_user_one",:disabled=>false,:full_name=>"XYZ"})
         @active_user_two = mock_user({:merge => {}, :user_name => "active_user_two",:disabled=>false,:full_name=>"ABC"})
         @inactive_user = mock_user({:merge => {}, :user_name => "inactive_user",:disabled=>true,:full_name=>"inactive_user"})

       end
       it "should filter active users and sort them by full_name by default" do
         User.should_receive(:view).with("by_full_name_filter_view",{:startkey=>["active"],:endkey=>["active",{}]}).and_return([@active_user_two,@active_user_one])
         get :index
         assigns[:users].should == [@active_user_two,@active_user_one]
       end

       it "should filter all users and sort them by full_name" do
         User.should_receive(:view).with("by_full_name_filter_view",{:startkey=>["all"],:endkey=>["all",{}]}).and_return([@active_user_two,@inactive_user,@active_user_one])
         get :index, :sort => "full_name", :filter=>"all"
         assigns[:users].should == [@active_user_two,@inactive_user,@active_user_one]
       end

       it "should filter all users and sort them by user_name" do
         User.should_receive(:view).with("by_user_name_filter_view",{:startkey=>["all"],:endkey=>["all",{}]}).and_return([@active_user_one,@active_user_two,@inactive_user])
         get :index, :sort => "user_name",:filter=>"all"
         assigns[:users].should == [@active_user_one,@active_user_two,@inactive_user]
       end

       it "should filter active users and sort them by full_name" do
         User.should_receive(:view).with("by_full_name_filter_view",{:startkey=>["active"],:endkey=>["active",{}]}).and_return([@active_user_two,@active_user_one])
         get :index, :sort => "full_name", :filter=>"active"
         assigns[:users].should == [@active_user_two,@active_user_one]
       end

       it "should filter active users and sort them by user_name" do
         User.should_receive(:view).with("by_user_name_filter_view",{:startkey=>["active"],:endkey=>["active",{}]}).and_return([@active_user_one,@active_user_two])
         get :index, :sort => "user_name", :filter=>"active"
         assigns[:users].should == [@active_user_one,@active_user_two]
       end
    end


    it "assigns users_details for backbone" do
      User.stub(:view).and_return([@user])
      get :index
      users_details = assigns[:users_details]
      users_details.should_not be_nil
      user_detail = users_details[0]
      user_detail[:user_name].should == "someone"
      user_detail[:user_url].should_not be_blank
    end

    it "should return error if user is not authorized" do
      fake_login
      mock_user = stub_model User
      get :index
      response.should be_forbidden
    end

    it "should authorize index page for read only users" do
      user = User.new(:user_name => 'view_user')
      user.stub(:roles).and_return([Role.new(:permissions => [Permission::USERS[:view]])])
      fake_login user
      get :index
      assigns(:access_error).should be_nil
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      mock_user = double(:user_name => "fakeadmin")
      User.stub(:get).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
    end

    it "should flash an error and go to listing page if the resource is not found" do
      User.stub(:get).with("invalid record").and_return(nil)
      get :show, :id => "invalid record"
      flash[:error].should == "User with the given id is not found"
      response.should redirect_to(:action => :index)
    end

    it "should show self user for non-admin" do
      session = fake_login
      get :show, :id => session.user.id
      response.should_not be_forbidden
    end

    it "should not show non-self user for non-admin" do
      fake_login
      mock_user = double({:user_name => 'some_random'})
      User.stub(:get).with("37").and_return(mock_user)
      get :show, :id => "37"
      response.status.should == 403
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      user = stub_model User
      User.stub(:new).and_return(user)
      get :new
      assigns[:user].should equal(user)
    end

    it "should assign all the available roles as @roles" do
      roles = ["roles"]
      Role.stub(:all).and_return(roles)
      get :new
      assigns[:roles].should == roles
    end

    it "should throw error if an user without authorization tries to access" do
      fake_login_as(Permission::USERS[:view])
      get :new
      response.status.should == 403
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      Role.stub(:all).and_return(["roles"])
      mock_user = stub_model(User, :user_name => "Test Name", :full_name => "Test")
      User.stub(:get).with("37").and_return(mock_user)
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
      assigns[:roles].should == ["roles"]
    end

    it "should not allow editing a non-self user for users without access" do
      fake_login_as(Permission::USERS[:view])
      User.stub(:get).with("37").and_return(mock_user(:full_name => "Test Name"))
      get :edit, :id => "37"
      response.should be_forbidden
    end

    it "should allow editing a non-self user for user having edit permission" do
      fake_login_as(Permission::USERS[:create_and_edit])
      mock_user = stub_model(User, :full_name => "Test Name", :user_name => 'fakeuser')
      User.stub(:get).with("24").and_return(mock_user)
      get :edit, :id => "24"
      response.status.should_not == 403
    end
  end


  describe "DELETE destroy" do
    it "destroys the requested user" do
      User.should_receive(:get).with("37").and_return(mock_user)
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the users list" do
      User.stub(:get).and_return(mock_user(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(users_url)
    end

    it "should not allow a destroy" do
      fake_login_as(Permission::USERS[:create_and_edit])
      User.stub(:get).and_return(mock_user(:destroy => true))
      delete :destroy, :id => "37"
      response.status.should == 403
    end

    it "should allow user deletion for relevant user role" do
      fake_login_as(Permission::USERS[:destroy])
      mock_user = stub_model User
      User.should_receive(:get).with("37").and_return(mock_user)
      mock_user.should_receive(:destroy).and_return(true)
      delete :destroy, :id => "37"
      response.status.should_not == 403
    end
  end

  describe "POST update" do
    context "when not admin user" do
      it "should not allow to edit admin specific fields" do
        fake_login
        mock_user = double({:user_name => "User_name"})
        User.stub(:get).with("24").and_return(mock_user)
        controller.stub(:current_user_name).and_return("test_user")
        mock_user.stub(:has_role_ids?).and_return(false)
        post :update, {:id => "24", :user => {:user_type => "Administrator"}}
        response.status.should == 403
      end
    end

    context "disabled flag" do
      it "should not allow to edit disable fields for non-disable users" do
        fake_login_as(Permission::USERS[:create_and_edit])
        user = stub_model User, :user_name => 'some name'
        params = { :id => '24', :user => { :disabled => true } }
        User.stub :get => user
        post :update, params
        response.should be_forbidden
      end

      it "should allow to edit disable fields for disable users" do
        fake_login_as(Permission::USERS[:disable])
        user = stub_model User, :user_name => 'some name'
        params = { :id => '24', :user => { :disabled => true } }
        User.stub :get => user
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        post :update, params
        response.should_not be_forbidden
      end

    end
    context "create a user" do
      it "should create admin user if the admin user type is specified" do
        fake_login_as(Permission::USERS[:create_and_edit])
        mock_user = User.new
        User.should_receive(:new).with({"role_ids" => %w(abcd)}).and_return(mock_user)
        mock_user.should_receive(:save).and_return(true)
        post :create, {"user" => {"role_ids" => %w(abcd)}}
      end

      it "should render new if the given user is invalid and assign user,roles" do
        mock_user = User.new
        Role.stub(:all).and_return("some roles")
        User.should_receive(:new).and_return(mock_user)
        mock_user.should_receive(:save).and_return(false)
        put :create, {:user => {:role_ids => ["wxyz"]}}
        response.should render_template :new
        assigns[:user].should == mock_user
        assigns[:roles].should == "some roles"
      end
    end
  end

  describe "POST update unverified user" do
    it "should set verify to true, if user is invalid" do
      controller.stub(:authorize!).and_return(true)
      User.should_receive(:get).with("unique_id").and_return(double("user", :update_attributes => false, :verified? => false))
      post :update, {:id => "unique_id", :user => {:verified => true}}
      controller.params[:verify].should be_true
    end

    it "should update all the children of recently verified users" do
      mock_user = User.new(:user_name => "user", :verified => false)
      controller.stub(:authorize!).and_return(true)
      child1 = double("child")
      child2 = double("child")
      mock_user.stub(:update_attributes).and_return(true)
      User.should_receive(:get).with("unique_id").and_return(mock_user)
      child1.should_receive(:verified=).with(true)
      child1.should_receive(:save)
      child2.should_receive(:verified=).with(true)
      child2.should_receive(:save)
      Child.should_receive(:all_by_creator).with("user").and_return([child1,child2])
      post :update, {:id => "unique_id", :user => {:verified => true}}
    end

    it "should call verify_children only for recently verified users" do
      mock_user = User.new(:user_name => "user", :verified => true)
      mock_user.stub(:update_attributes).and_return(true)
      User.should_receive(:get).with("unique_id").and_return(mock_user)
      Child.should_not_receive(:all_by_creator)
      post :update, {:id => "unique_id", :user => {:verified => true}}
    end
  end

  describe "GET change_password" do
    before :each do
      @user = User.new(:user_name => 'fakeuser')
      @mock_change_form = double()
      fake_login @user
      @mock_params = { "mock" => "mock" }
      Forms::ChangePasswordForm.stub(:new).with(@mock_params).and_return(@mock_change_form)
    end

    it "should show update password form" do
      Forms::ChangePasswordForm.stub(:new).with(:user => @user).and_return(@mock_change_form)
      get :change_password
      assigns[:change_password_request].should == @mock_change_form
      response.should render_template :change_password
    end

    it "should make password request from parameters" do
      @mock_change_form.should_receive(:user=).with(@user).and_return(nil)
      @mock_change_form.should_receive(:execute).and_return(true)

      post :update_password, { :forms_change_password_form => @mock_params }
      flash[:notice].should == "Password changed successfully"
      response.should redirect_to :action => :show, :id => @user.id
    end

    it "should show error when any of the fields is wrong" do
      @mock_change_form.should_receive(:user=).with(@user).and_return(nil)
      @mock_change_form.should_receive(:execute).and_return(false)

      post :update_password, { :forms_change_password_form => @mock_params }
      response.should render_template :change_password
    end
  end

  describe "register_unverified" do
    it "should set verified status to false" do
      User.should_receive(:find_by_user_name).and_return(nil)
      User.should_receive(:new).with("user_name" => "salvador", "verified" => false, "password" => "password", "password_confirmation" => "password").and_return(user = "some_user")
      user.should_receive :save!

      post :register_unverified, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}

      response.should be_ok
    end

    it "should not attempt to create a user if already exists" do
      User.should_receive(:find_by_user_name).and_return("something that is not nil")
      User.should_not_receive(:new)

      post :register_unverified, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}
      response.should be_ok
    end
  end

  describe "index unverified users" do
    it "should list all unverfied users" do
      unverified_users = [double("user")]
      User.should_receive(:all_unverified).and_return(unverified_users)
      get :unverified
      assigns[:users].should == unverified_users
      flash[:verify].should == "Please select a role before verifying the user"
    end

    it "should show page name" do
      get :unverified
      assigns[:page_name].should == "Unverified Users"
    end
  end

end
