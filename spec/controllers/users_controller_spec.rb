require 'spec_helper'

describe UsersController do
  before do
    fake_admin_login
  end

  before(:each) do
    fake_session = Session.new()
    fake_session.stub(:admin?).with(no_args()).and_return(true)
    Session.stub(:get).and_return(fake_session)
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  describe "GET index" do
    it "assigns all users as @users" do
      User.stub!(:view).and_return([mock_user])
      get :index
      assigns[:users].should == [mock_user]
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      User.stub!(:get).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
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
      User.stub!(:get).with("37").and_return(mock_user)
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

end
