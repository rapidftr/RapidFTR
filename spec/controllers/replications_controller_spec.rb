require 'spec_helper'

describe ReplicationsController do

  it "should authenticate configuration request through internal _users database of couchdb" do
    Replication.should_receive(:authenticate_with_internal_couch_users).with("rapidftr", "rapidftr").and_return(true)
    post :configuration, {:user_name => "rapidftr", :password => "rapidftr"}
  end

end