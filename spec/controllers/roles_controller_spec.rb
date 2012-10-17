require 'spec_helper'

describe RolesController do

  describe "non-admin user" do

    it "should not allow non-admin user to access any roles action" do
      fake_limited_login
      get :index
      response.should render_template("#{Rails.root}/public/403.html")
      post :create
      response.should render_template("#{Rails.root}/public/403.html")
      get :new
      response.should render_template("#{Rails.root}/public/403.html")
    end

  end

  before(:each) do
    fake_admin_login
  end

  it "should create the role with the given params" do
    params = {"name" => "some_role", "description" => "roles description", "permissions" => [Permission::ADMIN, Permission::LIMITED]}
    Role.should_receive(:new).with(params).and_return(mock(:save => true))

    post :create, {:role => params}

    response.should redirect_to(roles_path)
  end

  it "should throw error if the role is invalid" do
    params = {"permissions" => [Permission::ADMIN]}
    Role.should_receive(:new).and_return(role = mock_model(Role))
    role.should_receive(:save).and_return(false)

    post :create, {:role => params}

    assigns(:role).should == role
    response.should render_template(:new)
  end

  it "should remove empty permission before storing it" do
    params = {:permissions => ["", "admin", "", "limited"]}
    Role.should_receive(:new).with({"permissions" => ["admin", "limited"]}).and_return(role = mock_model(Role, :save => true))
    post :create, {:role => params}
  end

  it "should render the index page" do
    Role.should_receive(:all).and_return("all the roles!")

    get :index

    response.should render_template :index
    assigns(:roles).should == "all the roles!"
  end

  it "should render the new page" do
    get :new

    response.should render_template :new
    assigns(:role).should == Role.new
  end

end
