require 'spec_helper'

describe UserHistoriesController, :type => :controller do

  before do
    fake_admin_login
  end

  it "should have restful route for GET" do
    assert_routing({:method => 'get', :path => '/users/1/history'},
                   {:controller => "user_histories", :action => "index", :id => "1"})
  end

  it "should pass ordered histories and child id for user to view" do
    history1 = {"user_name" => "some user", "datetime" => 1.day.ago.to_s}
    history2 = {"user_name" => "some user", "datetime" => 1.week.ago.to_s}
    expect(User).to receive(:get).with("1").and_return(double(:user_name => (user_name = "some user")))
    expect(Child).to receive(:all_connected_with).with(user_name).and_return([
      double(:id => "other_id", :name => "other_name", :histories => [history2]),
      double(:id => "another_id", :name => "another_name", :histories => [history1])
    ])

    get :index, :id => "1"

    expect(assigns(:histories)).to eq([history1.merge(:child_id => "another_id"), history2.merge(:child_id => "other_id")])
  end

  it "should remove history entries for other users" do
    expect(User).to receive(:get).with("1").and_return(double(:user_name => (user_name = "some user")))
    history1 = {"user_name" => "some user", "datetime" => 1.day.ago.to_s}
    history2 = {"user_name" => "some other user", "datetime" => 1.week.ago.to_s}
    expect(Child).to receive(:all_connected_with).with(user_name).and_return([
      double(:id => "other_id", :name => "other_name", :histories => [history2]),
      double(:id => "another_id", :name => "another_name", :histories => [history1])
    ])

    get :index, :id => "1"

    expect(assigns(:histories)).to eq([history1.merge(:child_id => "another_id")])
  end

  it "should set the page name to the user" do
    allow(User).to receive(:get).and_return(double(:user_name => "some_user"))
    get :index, :id => "some_id"
    expect(assigns(:page_name)).to eq("History of some_user")
  end
end
