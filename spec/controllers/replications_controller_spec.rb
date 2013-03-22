require 'spec_helper'

describe ReplicationsController do

  it "should authenticate configuration request through internal _users database of couchdb" do
    config = { "a" => "a", "b" => "b", "c" => "c" }
    CouchSettings.instance.should_receive(:authenticate).with("rapidftr", "rapidftr").and_return(true)
    Replication.should_receive(:couch_config).and_return(config)
    post :configuration, { :user_name => "rapidftr", :password => "rapidftr" }
    target_json = JSON.parse(response.body)
    target_json.should == config
  end

  it "should render devices index page after saving a replication" do
    fake_login_as
    mock_replication = Replication.new
    Replication.should_receive(:new).and_return(mock_replication)
    mock_replication.should_receive(:save).and_return(true)
    post :create
    response.should redirect_to(devices_path)
  end

end