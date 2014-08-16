require 'spec_helper'

describe RolesController, :type => :controller do

  describe "GET index" do

    it "should show page name" do
      fake_login_as(Permission::ROLES[:view])
      mock = double
      expect(Role).to receive(:by_name).and_return([mock])
      get :index
      expect(assigns[:page_name]).to eq("Roles")
    end

    it "should allow user to view the roles" do
      fake_login_as(Permission::ROLES[:view])
      mock = double
      expect(Role).to receive(:by_name).and_return([mock])
      get :index
      expect(response).not_to be_forbidden
      expect(assigns(:roles)).to eq([mock])
    end

    it "should not allow user without view permission to view roles" do
      fake_login_as(Permission::USERS[:view])
      get :index
      expect(response).to be_forbidden
    end
  end

  describe "GET edit" do

    it "should allow user to edit roles " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role, :id => "10"
      expect(Role).to receive(:get).with(mock.id).and_return(mock)
      get :edit, :id => mock.id
      expect(response).not_to be_forbidden
      expect(assigns(:role)).to eq(mock)
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as(Permission::USERS[:view])
      Role.stub :get => stub_model(Role)
      get :edit, :id => "10"
      expect(response).to be_forbidden
    end

  end

  describe "GET show" do

    it "should allow user to view roles " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role, :id => "10"
      expect(Role).to receive(:get).with(mock.id).and_return(mock)
      get :show, :id => mock.id
      expect(assigns(:role)).to eq(mock)
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as(Permission::USERS[:view])
      Role.stub :get => stub_model(Role)
      get :show, :id => "10"
      expect(response).to be_forbidden
    end

  end

  describe "POST new" do
    it "should allow valid user to create roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      expect(Role).to receive(:new).and_return(mock)
      post :new
      expect(response).not_to be_forbidden
      expect(assigns(:role)).to eq(mock)
    end

    it "should not allow user without permission to create new roles" do
      fake_login_as(Permission::USERS[:view])
      expect(Role).not_to receive(:new)
      post :new
      expect(response).to be_forbidden
    end
  end

  describe "POST update" do
    it "should allow valid user to update roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role, :id => "1"
      role_mock = { "mock" => "mock" }

      expect(mock).to receive(:update_attributes).with(role_mock).and_return(true)
      expect(Role).to receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => role_mock
      expect(response).not_to be_forbidden
      expect(assigns(:role)).to eq(mock)
      expect(flash[:notice]).to eq("Role details are successfully updated.")
    end

    it "should return error if update attributes is not invoked " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role, :id => "1"
      role_mock = { "mock" => "mock" }

      expect(mock).to receive(:update_attributes).with(role_mock).and_return(false)
      expect(Role).to receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => role_mock
      expect(response).not_to be_forbidden
      expect(assigns(:role)).to eq(mock)
      expect(flash[:error]).to eq("Error in updating the Role details.")
    end

    it "should not allow invalid user to update roles" do
      fake_login_as(Permission::ROLES[:view])
      mock = stub_model Role, :id => "1"
      expect(mock).not_to receive(:update_attributes).with(anything)
      expect(Role).to receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => {}
      expect(response).to be_forbidden
    end
  end

  describe "POST create" do
    it "should not allow invalid user to create roles" do
      fake_login_as(Permission::ROLES[:view])
      role_mock = double
      expect(Role).not_to receive(:new).with(anything)
      post :create, :role => role_mock
      expect(response).to be_forbidden
    end

    it "should allow valid user to create roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      role_mock = { "mock" => "mock" }
      expect(role_mock).to receive(:save).and_return(true)
      expect(Role).to receive(:new).with(role_mock).and_return(role_mock)
      post :create, :role => role_mock
      expect(response).to redirect_to(roles_path)
      expect(response).not_to be_forbidden
    end

    it "should take back to new page if save failed" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      role_mock = double
      expect(role_mock).to receive(:save).and_return(false)
      expect(Role).to receive(:new).with(anything).and_return(role_mock)
      post :create, :role => role_mock
      expect(response).to render_template(:new)
      expect(response).not_to be_forbidden
    end

  end

end
