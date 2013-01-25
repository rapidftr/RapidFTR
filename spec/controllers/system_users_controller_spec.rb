require 'spec_helper'

describe SystemUsersController do

  it "should list all system users" do
    fake_login_as Permission::SYSTEM[:replication_users]
    SystemUsers.should_receive(:all)
    get :index
  end

  describe "create system users" do
    it "should create system users" do
      fake_login_as Permission::SYSTEM[:replication_users]
      params = {:system_users => {:name => "test_user", :password => "test_password"}}
      mock_system_users = SystemUsers.new
      SystemUsers.should_receive(:new).and_return(mock_system_users)
      mock_system_users.should_receive(:save).and_return(true)
      post :create, params
    end

    it "should redirect to the system users new page if there is a validation error" do
      fake_login_as Permission::SYSTEM[:replication_users]
      params = {:system_users => {:name => "test_user", :password => "test_password"}}
      mock_system_users = SystemUsers.new
      SystemUsers.should_receive(:new).and_return(mock_system_users)
      mock_system_users.should_receive(:save).and_return(false)
      post :create, params
      response.should render_template :new
    end
  end

  it "should edit system users" do
    fake_login_as Permission::SYSTEM[:replication_users]
    SystemUsers.should_receive(:get).with("org.couchdb.user:abcd").and_return(SystemUsers.new)
    get :edit, {:id => "abcd"}
    response.should render_template :edit
  end

  describe "update user" do
    it "should update system user" do
      fake_login_as Permission::SYSTEM[:replication_users]
      mock_user = SystemUsers.new({:name => "test_user", :password => "test_password" })
      SystemUsers.should_receive(:get).with("org.couchdb.user:test_user").and_return(mock_user)
      mock_user.should_receive(:update_attributes).and_return(true)
      put :update, {:id =>"test_user",:system_users => {:name => "test_user", :password => "test_password"}}
      response.should redirect_to(:action => :index)
    end

    it "should not update system user if username is changed" do
      fake_login_as Permission::SYSTEM[:replication_users]
      mock_user = SystemUsers.new({:name => "test_user", :password => "test_password" })
      SystemUsers.should_receive(:get).with("org.couchdb.user:abcd").and_return(mock_user)
      mock_user.should_not_receive(:update_attributes)
      put :update, {:id =>"abcd",:system_users => {:name => "abcd", :password => "test_password"}}
      response.should redirect_to(:action => :edit)
    end

  end

  it "should destroy the user" do
    fake_login_as Permission::SYSTEM[:replication_users]
    mock_user = SystemUsers.new
    SystemUsers.should_receive(:get).with("org.couchdb.user:test_user").and_return(mock_user)
    mock_user.should_receive(:destroy)
    delete :destroy, {:id => "test_user"}
    response.should redirect_to(:action => :index)
  end

end

