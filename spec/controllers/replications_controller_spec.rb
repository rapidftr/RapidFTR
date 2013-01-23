require 'spec_helper'

describe ReplicationsController do

  it "should authenticate configuration request through internal _users database of couchdb" do
    Replication.should_receive(:authenticate_with_internal_couch_users).with("rapidftr", "rapidftr").and_return(true)
    target_url = "http://rapidftr:rapidftr@localhost:5984/rapidftr_child_test"
    Replication.should_receive(:configuration).with("rapidftr", "rapidftr").and_return({:target => target_url})
    post :configuration, {:user_name => "rapidftr", :password => "rapidftr"}
    target_json = JSON.parse(response.body)
    target_json["target"].should == target_url
  end

  it "should render devices index page after saving a replication" do
    fake_login_as
    mock_replication = Replication.new
    replication_details = {:description => "description", :remote_url => "url", :user_name => "username", :password => "password"}
    Replication.should_receive(:new).and_return(mock_replication)
    mock_replication.should_receive(:save).and_return(true)
    post :create, :replication => replication_details
    response.should redirect_to(devices_path)
  end
end