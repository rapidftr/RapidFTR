require 'spec_helper'

describe ChildHistoriesController do
  before do
    fake_admin_login
  end

  it "should create child variable for view" do
    child = build :child
    get :index, :id => child.id
    assigns(:child).should == child
  end

  it "should set the page name to the child short ID" do
    child = build :child, :unique_identifier => "1234"
    get :index, :id => child.id
    assigns(:page_name).should == "History of 1234"
  end

end
