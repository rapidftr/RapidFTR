require 'spec_helper'
require 'timeout'

describe Replication do

  REPLICATION_DB = COUCHDB_SERVER.database('_replicator')

  before :each do
    all_docs(REPLICATION_DB).each { |rep| REPLICATION_DB.delete_doc rep if rep["rapidftr_env"] == Rails.env rescue nil }
  end

  after :each do
    all_docs(REPLICATION_DB).each { |rep| REPLICATION_DB.delete_doc rep if rep["rapidftr_env"] == Rails.env rescue nil }
  end

  before :each do
    Replication.stub :models_to_sync => [ Role, Child, User ]
    @rep = build :replication, :remote_couch_config => {
      "target" => "http://couch:1234",
      "databases" => {
        "User"  => "remote_user_db_name",
        "Child" => "remote_child_db_name",
        "Role"  => "remote_child_role_name"
      }
    }

    @rep["_id"] = 'test_replication_id'
    @default_config = { "rapidftr_ref_id" => @rep.id }
  end

  describe 'validations' do
    it 'should be valid' do
      r = build :replication
      r.should be_valid
    end

    it 'should have description' do
      r = build :replication, :description => nil
      r.should_not be_valid
      r.errors[:description].should_not be_empty
    end

    it 'should have remote url' do
      r = build :replication, :remote_app_url => nil
      r.should_not be_valid
      r.errors[:remote_app_url].should_not be_empty
    end

    it 'should have user name' do
       r = build :replication, :password => nil
       r.should_not be_valid
       r.errors[:password].should_not be_empty
     end

    it 'should have user name' do
      r = build :replication, :username => nil
      r.should_not be_valid
      r.errors[:username].should_not be_empty
    end

    it 'should allow only http or https' do
      r = build :replication, :remote_app_url => 'abcd://app:3000'
      r.should_not be_valid
      r.errors[:remote_app_url].should_not be_empty
    end

    it 'should validate remote couch config' do
      r = build :replication, :remote_app_url => 'http://app:3000'
      expect(r).to receive(:save_remote_couch_config).and_return(false).and_call_original
      expect(r).not_to be_valid
      r.errors[:save_remote_couch_config].should_not be_empty
    end
  end

  describe 'getters' do
    it 'should return what models to sync' do
      reset Replication
      Replication.models_to_sync.should == [ Role, Child, User, MobileDbKey, Device ]
    end

    it 'should sync roles first, otherwise users will sync first and start throwing role errors' do
      reset Replication
      Replication.models_to_sync.first.should == Role
    end

    it 'should return the couchdb url without the source username and password' do
      CouchSettings.instance.stub :ssl_enabled_for_couch? => false, :host => "couchdb", :username => "rapidftr", :password => "rapidftr", :port => 5986
      target_hash = Replication.couch_config
      target_hash[:target].should == "http://couchdb:5986/"
    end

    it 'should return HTTPS url when enabled in Couch' do
      CouchSettings.instance.stub :ssl_enabled_for_couch? => true, :host => "couchdb", :username => "rapidftr", :password => "rapidftr", :port => 6986
      target_hash = Replication.couch_config
      target_hash[:target].should == "https://couchdb:6986/"
    end

    it "should include database names of models to sync" do
      Replication.stub :models_to_sync => [ User ]
      Replication.couch_config[:databases].should include "User" => User.database.name
    end

    it 'should generate app uri' do
      @rep.remote_app_uri.to_s.should == 'http://app:1234/'
    end

    it 'should generate couch uri' do
      @rep.username = @rep.password = nil
      @rep.remote_couch_uri.to_s.should == 'http://couch:1234/'
    end

    it 'should generate couch uri with username and password' do
      @rep.username = 'test_user'
      @rep.password = 'test_password'
      @rep.remote_couch_uri.to_s.should == 'http://test_user:test_password@couch:1234/'
    end

    it 'should replace localhost in Couch URL with the actual host name from App URL' do
      @rep.remote_app_url = "https://app:3000"
      @rep.username = @rep.password = nil
      @rep.stub :remote_couch_config => { "target" => "http://localhost:1234" }
      @rep.remote_couch_uri.to_s.should == 'http://app:1234/'
    end

    it 'should normalize remote_app_url upon saving' do
      @rep.save
      @rep.remote_app_url.should == @rep.remote_app_uri.to_s
    end

    it 'should create push configuration for some database' do
      @rep.push_config(User).should include "source" => User.database.name, "target" => "http://test_user:test_password@couch:1234/remote_user_db_name", "rapidftr_ref_id" => @rep.id, "rapidftr_env" => Rails.env
    end

    it 'should create pull configuration for some database' do
      @rep.pull_config(User).should include "target" => User.database.name, "source" => "http://test_user:test_password@couch:1234/remote_user_db_name", "rapidftr_ref_id" => @rep.id, "rapidftr_env" => Rails.env
    end

    it 'should return configurations for push/pull of user/children/role' do
      Replication.stub :models_to_sync => [ User, User, User ]
      @rep.should_receive(:push_config).exactly(3).times.with(User).and_return("a")
      @rep.should_receive(:pull_config).exactly(3).times.with(User).and_return("b")
      @rep.build_configs.should == ["a", "b", "a", "b", "a", "b"]
    end

    it 'should return all replication documents' do
      @rep.stub :replicator_docs =>  [ { "test" => "1" }, @default_config, { "test" => "2" }, @default_config ]
      @rep.fetch_configs.should == [ @default_config, @default_config ]
    end

    it 'should cache all replication documents' do
      @rep.stub :replicator_docs =>  [ { "test" => "1" }, @default_config, { "test" => "2" }, @default_config ]
      @rep.fetch_configs.should == [ @default_config, @default_config ]
      @rep.stub :replicator_docs =>  [ { "test" => "1" }, @default_config, @default_config, @default_config ]
      @rep.fetch_configs.should == [ @default_config, @default_config ]
    end

    it 'should invalidate replication document cache' do
      @rep.stub :replicator_docs =>  [ { "test" => "1" }, @default_config, { "test" => "2" }, @default_config ]
      @rep.fetch_configs.should == [ @default_config, @default_config ]
      @rep.send :invalidate_fetch_configs
      @rep.stub :replicator_docs => [ { "test" => "1" }, @default_config, @default_config, @default_config ]
      @rep.fetch_configs.should == [ @default_config, @default_config, @default_config ]
    end

    it 'should invalidate replication document cache upon saving' do
      @rep.should_receive(:invalidate_fetch_configs).and_return(true)
      @rep["_id"] = nil
      @rep.save!
    end

    it 'should start replication' do
      configuration = double()
      @rep.stub :build_configs => [ configuration, configuration, configuration ]
      @rep.stub :save_without_callbacks => nil

      @rep.send(:replicator).should_receive(:save_doc).exactly(3).times.with(configuration).and_return(nil)
      @rep.start_replication
    end

    it 'should stop replication and invalidate fetch config' do
      configuration = double()
      @rep.stub :fetch_configs => [ configuration, configuration, configuration ]
      @rep.stub :save_without_callbacks => nil

      @rep.send(:replicator).should_receive(:delete_doc).exactly(3).times.with(configuration).and_return(nil)
      @rep.should_receive(:invalidate_fetch_configs).and_return(nil)
      @rep.stop_replication
    end

    it 'should stop replication before starting' do
      @rep.should_receive(:stop_replication).and_return(nil)
      @rep.start_replication
    end
  end

  describe 'timestamp' do
    it 'timestamp should be nil' do
      @rep.stub :fetch_configs => []
      @rep.timestamp.should be_nil
    end

    it 'timestamp should be latest timestamp' do
      latest = 5.minutes.ago
      @rep.stub :fetch_configs => [
        @default_config.merge("_replication_state_time" => 1.day.ago.to_s),
        @default_config.merge("_replication_state_time" => latest.to_s),
        @default_config.merge("_replication_state_time" => 2.days.ago.to_s)
      ]

      @rep.timestamp.should == Time.zone.parse(latest.to_s)
    end
  end

  describe 'status' do
    before :each do
      @rep.stub :timestamp => nil
    end

    it 'statuses should return array of statuses' do
      @rep.stub :fetch_configs => [
        @default_config.merge("_replication_state" => 'a'), @default_config.merge("_replication_state" => 'b'),
        @default_config.merge("_replication_state" => 'c'), @default_config.merge("_replication_state" => 'd')
      ]
      @rep.statuses.should == [ 'a', 'b', 'c', 'd' ]
    end

    it 'statuses should substitute triggered if status is empty' do
      @rep.stub :fetch_configs => [
        @default_config.merge("_replication_state" => nil), @default_config.merge("_replication_state" => 'd')
      ]
      @rep.statuses.should == [ 'triggered', 'd' ]
    end

    it 'active should be false if no replication was configured' do
      @rep.stub :statuses => [ ]
      @rep.should_not be_active
    end

    it 'active should be false if no operations have status as "triggered"' do
      @rep.stub :statuses => [ "abcd", "abcd" ]
      @rep.should_not be_active
    end

    it 'active should be true if any operation has status as "triggered"' do
      @rep.stub :statuses => [ "triggered", "abcd" ]
      @rep.should be_active
    end

    it 'active should be true if the replications completed less than 2 mins ago' do
      @rep.stub :statuses => [ "completed", "error" ], :timestamp => 1.minute.ago
      @rep.should be_active
    end

    it 'active should be false if the replications completed more than 2 mins ago' do
      @rep.stub :statuses => [ "completed", "error" ], :timestamp => 3.minutes.ago
      @rep.should_not be_active
    end

    it 'success should be true if all operations have status as "completed"' do
      @rep.stub :statuses => [ "completed", "completed" ]
      @rep.should be_success
    end

    it 'success should be false if any operation doesnt have status as "completed"' do
      @rep.stub :statuses => [ "completed", "abcd" ]
      @rep.should_not be_success
    end
  end

  describe 'reindex' do
    it 'should mark for reindexing whenever a record is being saved' do
      @rep["_id"] = nil
      @rep.needs_reindexing = false
      @rep.save
      @rep.needs_reindexing.should be_true
    end

    it 'should set needs reindexing to true when starting replication' do
      @rep.needs_reindexing = false
      @rep.should_receive(:needs_reindexing=).with(true).and_return(true)
      @rep.should_receive(:save_without_callbacks).and_return(true)
      @rep.start_replication
    end

    it 'should trigger reindex after completing' do
      @rep.stub :active? => false, :needs_reindexing? => true
      @rep.should_receive(:trigger_local_reindex).and_return(nil)
      @rep.should_receive(:trigger_remote_reindex).and_return(nil)
      @rep.check_status_and_reindex
    end

    it 'should not trigger reindex twice' do
      @rep.stub :active? => false, :needs_reindexing? => false
      @rep.should_not_receive(:trigger_local_reindex)
      @rep.should_not_receive(:trigger_remote_reindex)
      @rep.check_status_and_reindex
    end

    it 'should trigger local reindexing' do
      Child.should_receive(:reindex!).ordered.and_return(nil)
      @rep.should_receive(:needs_reindexing=).with(false).ordered.and_return(nil)
      @rep.should_receive(:save_without_callbacks).ordered.and_return(nil)
      @rep.send :trigger_local_reindex
    end

    it 'should trigger remote reindexing' do
      uri = @rep.remote_app_uri
      @rep.stub :remote_app_uri => uri

      Net::HTTP.should_receive(:post_form).with(uri, {}).and_return(nil)
      @rep.send :trigger_remote_reindex
      uri.path.should == '/children/reindex'
    end

    it 'should schedule reindexing every 5m' do
      scheduler = double()
      scheduler.should_receive(:every).with('5m').and_yield

      replication = build :replication
      replication.should_receive(:check_status_and_reindex).and_return(nil)
      Replication.stub :all => [ replication ]

      Replication.schedule scheduler
    end
  end

  def all_docs(db)
    db.documents["rows"].map { |doc| db.get doc["id"] unless doc["id"].include? "_design" }.compact
  end

  def delete_all_docs(db)
    all_docs(db).each { |doc| db.delete_doc doc rescue nil }
  end

  def wait_for_doc(db, prop, value, present=true, seconds=60)
    Timeout::timeout(seconds) do
      until present == all_docs(db).any? { |doc| doc[prop] == value }
        sleep 0.1
      end
    end
  end

end
