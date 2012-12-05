require 'spec_helper'

describe RolesController do

  describe "GET index" do
    it "should allow user to view the roles" do
      fake_login_as(Permission::ROLES[:view])
      mock = mock()
      Role.should_receive(:by_name).and_return([mock])
      get :index
      response.should_not be_forbidden
      assigns(:roles).should == [mock]
    end

    it "should not allow user without view permission to view roles" do
      fake_login_as(Permission::USERS[:view])
      get :index
      response.should be_forbidden
    end
  end

  describe "GET edit" do

    it "should allow user to edit roles " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      Role.should_receive(:get).with(10).and_return(mock)
      get :edit, :id => 10
      response.should_not be_forbidden
      assigns(:role).should == mock
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as(Permission::USERS[:view])
      Role.stub :get => stub_model(Role)
      get :edit, :id => 10
      response.should be_forbidden
    end

  end

    describe "GET show" do

    it "should allow user to view roles " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      Role.should_receive(:get).with(10).and_return(mock)
      get :show, :id => 10
      assigns(:role).should == mock
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as(Permission::USERS[:view])
      Role.stub :get => stub_model(Role)
      get :show, :id => 10
      response.should be_forbidden
    end

  end

  describe "POST new" do
    it "should allow valid user to create roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      Role.should_receive(:new).and_return(mock)
      post :new
      response.should_not be_forbidden
      assigns(:role).should == mock
    end

    it "should not allow user without permission to create new roles" do
      fake_login_as(Permission::USERS[:view])
      Role.should_not_receive(:new)
      post :new
      response.should be_forbidden
    end
  end

  describe "POST update" do
    it "should allow valid user to update roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      role_mock = mock()

      mock.should_receive(:update_attributes).with(role_mock).and_return(true)
      Role.should_receive(:get).with(1).and_return(mock)
      post :update, :id => 1, :role => role_mock
      response.should_not be_forbidden
      assigns(:role).should == mock
      flash[:notice].should == "Role details are successfully updated."
    end

    it "should return error if update attributes is not invoked " do
      fake_login_as(Permission::ROLES[:create_and_edit])
      mock = stub_model Role
      role_mock = mock()

      mock.should_receive(:update_attributes).with(role_mock).and_return(false)
      Role.should_receive(:get).with(1).and_return(mock)
      post :update, :id => 1, :role => role_mock
      response.should_not be_forbidden
      assigns(:role).should == mock
      flash[:error].should == "Error in updating the Role details."
    end

    it "should not allow invalid user to update roles" do
      fake_login_as(Permission::ROLES[:view])
      mock = stub_model Role
      mock.should_not_receive(:update_attributes).with(anything)
      Role.should_receive(:get).with(1).and_return(mock)
      post :update, :id => 1, :role => {}
      response.should be_forbidden
    end
  end

  describe "POST create" do
    it "should not allow invalid user to create roles" do
      fake_login_as(Permission::ROLES[:view])
      role_mock = mock()
      Role.should_not_receive(:new).with(anything)
      post :create, :role => role_mock
      response.should be_forbidden
    end

    it "should allow valid user to create roles" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      role_mock = mock()
      role_mock.should_receive(:save).and_return(true)
      Role.should_receive(:new).with(role_mock).and_return(role_mock)
      post :create, :role => role_mock
      response.should redirect_to(roles_path)
      response.should_not be_forbidden
    end

    it "should take back to new page if save failed" do
      fake_login_as(Permission::ROLES[:create_and_edit])
      role_mock = mock()
      role_mock.should_receive(:save).and_return(false)
      Role.should_receive(:new).with(anything).and_return(role_mock)
      post :create, :role => role_mock
      response.should render_template(:new)
      response.should_not be_forbidden
    end

  end

end
