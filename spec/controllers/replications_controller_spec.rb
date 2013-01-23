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

end