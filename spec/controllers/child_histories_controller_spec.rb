require 'spec_helper'

describe ChildHistoriesController do
  before do
    fake_admin_login
  end

  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/children/1/history'},
                    {:controller => "child_histories", :action => "index", :id => "1"})
  end

  it "should use child_id param when retrieving the child" do
    Child.should_receive(:get).with("1").and_return(mock('child', :[] => []))
    get :index, :id => "1"
  end

  it "should create child variable for view" do
    Child.stub(:get).and_return "some_child"
    get :index, :id => "some_id"
    assigns(:child).should == "some_child"
  end

  it "should set the page name to the child" do
    Child.stub(:get).and_return "some_child"
    get :index, :id => "some_id"
    assigns(:page_name).should == "History of some_child"
  end
end
