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
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      User.stub!(:get).with("37").and_return(mock_user(:full_name => "Test Name"))
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
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

end
