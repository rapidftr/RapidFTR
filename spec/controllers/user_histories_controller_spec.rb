require 'spec_helper'

describe UserHistoriesController do

  before do
    fake_admin_login
  end

  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/users/1/history'},
                    {:controller => "user_histories", :action => "index", :id => "1"})
  end

  it "should pass ordered histories, child name and id for user to view" do
    history1 = {"user_name" => "some user", "datetime" => 1.day.ago.to_s}
    history2 = {"user_name" => "some user", "datetime" => 1.week.ago.to_s}
    User.should_receive(:get).with("1").and_return(mock(:user_name => (user_name = "some user")))
    Child.should_receive(:all_connected_with).with(user_name).and_return([
          mock(:id => "other_id", :name => "other_name", :histories => [history2]),
          mock(:id => "another_id", :name => "another_name", :histories => [history1])
    ])

    get :index, :id => "1"

    assigns(:histories).should == [history1.merge("child_id" => "another_id", "child_name" => "another_name"), history2.merge("child_id" => "other_id", "child_name" => "other_name")]
  end

  it "should remove history entries for other users" do
    User.should_receive(:get).with("1").and_return(mock(:user_name => (user_name = "some user")))
    history1 = {"user_name" => "some user", "datetime" => 1.day.ago.to_s}
    history2 = {"user_name" => "some other user", "datetime" => 1.week.ago.to_s}    
    Child.should_receive(:all_connected_with).with(user_name).and_return([
          mock(:id => "other_id", :name => "other_name", :histories => [history2]),
          mock(:id => "another_id", :name => "another_name", :histories => [history1])
    ])

    get :index, :id => "1"

    assigns(:histories).should == [history1.merge("child_id" => "another_id", "child_name" => "another_name")]
  end

  it "should set the page name to the user" do
    User.stub(:get).and_return(mock(:user_name => "some_user"))
    get :index, :id => "some_id"
    assigns(:page_name).should == "History of some_user"
  end
end