require 'spec_helper'

describe SystemUsersController, :type => :controller do

  it "should list all system users" do
    fake_login_as Permission::SYSTEM[:system_users]
    expect(SystemUsers).to receive(:all)
    get :index
  end

  it "should show page name" do
    fake_login_as
    get :new
    expect(assigns[:page_name]).to eq("Create a System User")
  end

  describe "create system users" do
    it "should create system users" do
      fake_login_as Permission::SYSTEM[:system_users]
      params = {:system_users => {:name => "test_user", :password => "test_password"}}
      mock_system_users = SystemUsers.new
      expect(SystemUsers).to receive(:new).and_return(mock_system_users)
      expect(mock_system_users).to receive(:save).and_return(true)
      post :create, params
    end

    it "should redirect to the system users new page if there is a validation error" do
      fake_login_as Permission::SYSTEM[:system_users]
      params = {:system_users => {:name => "test_user", :password => "test_password"}}
      mock_system_users = SystemUsers.new
      expect(SystemUsers).to receive(:new).and_return(mock_system_users)
      expect(mock_system_users).to receive(:save).and_return(false)
      post :create, params
      expect(response).to render_template :new
    end
  end

  it "should edit system users" do
    fake_login_as Permission::SYSTEM[:system_users]
    expect(SystemUsers).to receive(:get).with("org.couchdb.user:abcd").and_return(SystemUsers.new)
    get :edit, {:id => "abcd"}
    expect(response).to render_template :edit
  end

  describe "update user" do
    it "should update system user" do
      fake_login_as Permission::SYSTEM[:system_users]
      mock_user = SystemUsers.new({:name => "test_user", :password => "test_password" })
      expect(SystemUsers).to receive(:get).with("org.couchdb.user:test_user").and_return(mock_user)
      expect(mock_user).to receive(:update_attributes).and_return(true)
      put :update, {:id =>"test_user",:system_users => {:name => "test_user", :password => "test_password"}}
      expect(response).to redirect_to(:action => :index)
    end

    it "should not update system user if username is changed" do
      fake_login_as Permission::SYSTEM[:system_users]
      mock_user = SystemUsers.new({:name => "test_user", :password => "test_password" })
      expect(SystemUsers).to receive(:get).with("org.couchdb.user:abcd").and_return(mock_user)
      expect(mock_user).not_to receive(:update_attributes)
      put :update, {:id =>"abcd",:system_users => {:name => "abcd", :password => "test_password"}}
      expect(response).to redirect_to(:action => :edit)
    end

  end

  it "should destroy the user" do
    fake_login_as Permission::SYSTEM[:system_users]
    mock_user = SystemUsers.new
    expect(SystemUsers).to receive(:get).with("org.couchdb.user:test_user").and_return(mock_user)
    expect(mock_user).to receive(:destroy)
    delete :destroy, {:id => "test_user"}
    expect(response).to redirect_to(:action => :index)
  end

end
