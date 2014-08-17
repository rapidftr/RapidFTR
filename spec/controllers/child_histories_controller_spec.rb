require 'spec_helper'

describe ChildHistoriesController, :type => :controller do
  before do
    fake_admin_login
  end

  it "should create child variable for view" do
    child = create :child, :created_by => controller.current_user_name
    get :index, :id => child.id
    expect(assigns(:child)).to eq(child)
  end

  it "should set the page name to the child short ID" do
    child = create :child, :unique_identifier => "1234", :created_by => controller.current_user_name
    get :index, :id => child.id
    expect(assigns(:page_name)).to eq("History of 1234")
  end

end
