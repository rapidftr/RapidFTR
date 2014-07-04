require 'spec_helper'

describe ChildHistoriesController, :type => :controller do
  before do
    fake_admin_login
  end

  it "should create child variable for view" do
    child = build :child
    get :index, :id => child.id
    expect(assigns(:child)).to eq(child)
  end

  it "should set the page name to the child short ID" do
    child = build :child, :unique_identifier => "1234"
    get :index, :id => child.id
    expect(assigns(:page_name)).to eq("History of 1234")
  end

end
