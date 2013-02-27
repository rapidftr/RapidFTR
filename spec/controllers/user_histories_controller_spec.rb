require 'spec_helper'

describe UserHistoriesController do

  before do
    fake_admin_login
  end

  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/users/1/history'},
                    {:controller => "user_histories", :action => "index", :id => "1"})
  end

  it "should pass ordered histories for user to view" do
    history1 = {"datetime" => 1.day.ago.to_s}
    history2 = {"datetime" => 1.week.ago.to_s}
    User.should_receive(:get).with("1").and_return(mock(:user_name => (user_name = "some user")))
    Child.should_receive(:all_connected_with).with(user_name).and_return([mock(:histories => [history2]), mock(:histories => [history1])])

    get :index, :id => "1"

    assigns(:histories).should == [history1, history2]
  end
end