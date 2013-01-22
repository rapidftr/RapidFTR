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
      r = build :replication, :remote_url => nil
      r.should_not be_valid
      r.errors[:remote_url].should_not be_empty
    end

    it 'should allow only http or https' do
      r = build :replication, :remote_url => 'abcd://localhost:3000'
      r.should_not be_valid
      r.errors[:remote_url].should_not be_empty
    end
  end

  describe 'getters' do
    before :each do
      @rep = build :replication, :remote_url => 'localhost:1234'
      @rep.stub! :remote_config => { "target" => "localhost:1234" }
      @rep["_id"] = 'test_replication_id'
    end

    it 'should generate uri' do
      @rep.remote_uri.to_s.should == 'http://localhost:1234/'
    end

    it 'should generate push document id' do
      @rep.push_id.should == 'push-test-replication-id'
    end

    it 'should generate pull document id' do
      @rep.pull_id.should == 'pull-test-replication-id'
    end

    it 'should normalize remote_url upon saving' do
      @rep.save
      @rep.remote_url.should == @rep.remote_uri.to_s
    end

    it 'should return source' do
      @rep.source.should == Child.database.name
    end

    it 'should return target' do
      @rep.target.should == "http://localhost:1234/"
    end

    it 'should return push configuration' do
      @rep.push_config.should include "source" => @rep.source, "target" => @rep.target, "rapidftr_ref_id" => @rep["_id"], "rapidftr_env" => Rails.env
    end

    it 'should return pull configuration' do
      @rep.pull_config.should include "source" => @rep.target, "target" => @rep.source, "rapidftr_ref_id" => @rep["_id"], "rapidftr_env" => Rails.env
    end

    it 'should return push state' do
      @rep.stub :push_doc => { '_replication_state' => 'abcd' }
      @rep.push_state.should == 'abcd'
    end

    it 'should return pull state' do
      @rep.stub :pull_doc => { '_replication_state' => 'abcd' }
      @rep.pull_state.should == 'abcd'
    end

    describe 'timestamp' do
      before :each do
        @one_second_ago = 1.seconds.ago
      end

      it 'should be nil' do
        @rep.stub! :push_doc => nil, :pull_doc => nil
        @rep.timestamp.should be_nil
      end

      it 'should be push timestamp when pull timestamp is nil' do
        @rep.stub! :push_doc => { "_replication_state_time" => @one_second_ago }, :pull_doc => nil
        @rep.timestamp.should == @one_second_ago
      end

      it 'should be pull timestamp when push timestamp is nil' do
        @rep.stub! :push_doc => nil, :pull_doc => { "_replication_state_time" => @one_second_ago }
        @rep.timestamp.should == @one_second_ago
      end

      it 'should be push timestamp when pull timestamp is older' do
        @rep.stub! :push_doc => { "_replication_state_time" => @one_second_ago }, :pull_doc => { "_replication_state_time" => 2.seconds.ago }
        @rep.timestamp.should == @one_second_ago
      end

      it 'should be pull timestamp when push timestamp is older' do
        @rep.stub! :push_doc => { "_replication_state_time" => 2.seconds.ago }, :pull_doc => { "_replication_state_time" => @one_second_ago }
        @rep.timestamp.should == @one_second_ago
      end
    end

    describe 'statuses' do
      describe '#triggered' do
        it 'should be true' do
          @rep.stub! :push_state => 'abcd', :pull_state => 'triggered'
          @rep.should be_triggered
        end

        it 'should be true' do
          @rep.stub! :push_state => 'triggered', :pull_state => 'abcd'
          @rep.should be_triggered
        end

        it 'should be false' do
          @rep.stub! :push_state => 'abcd', :pull_state => 'abcd'
          @rep.should_not be_triggered
        end
      end

      describe '#completed' do
        it 'should be true' do
          @rep.stub! :push_state => 'completed', :pull_state => 'completed'
          @rep.should be_completed
        end

        it 'should be true' do
          @rep.stub! :push_state => 'abcd', :pull_state => 'completed'
          @rep.should_not be_completed
        end

        it 'should be true' do
          @rep.stub! :push_state => 'completed', :pull_state => 'abcd'
          @rep.should_not be_completed
        end
      end

      describe '#error' do
        it 'should be true' do
          @rep.stub! :push_state => 'abcd', :pull_state => 'error'
          @rep.should be_error
        end

        it 'should be true' do
          @rep.stub! :push_state => 'error', :pull_state => 'abcd'
          @rep.should be_error
        end

        it 'should be false' do
          @rep.stub! :push_state => 'abcd', :pull_state => 'abcd'
          @rep.should_not be_error
        end
      end

      describe '#status' do
        it 'should be triggered' do
          @rep.stub! :triggered? => true, :completed? => true
          @rep.status.should == 'triggered'
        end

        it 'should be completed' do
          @rep.stub! :triggered? => false, :completed? => true
          @rep.status.should == 'completed'
        end

        it 'should be error' do
          @rep.stub! :triggered? => false, :completed? => false
          @rep.status.should == 'error'
        end
      end
    end
  end

  ################# NOTE #################
  ## This will run on entire couch db   ##
  ## rather than on a single test       ##
  ## database. Do we want to run this   ##
  ## every time?                        ##
  ################# NOTE #################

  describe 'authenticate' do
    before :each do
      @auth_response = RestClient.post 'http://127.0.0.1:5984/_session', 'name=rapidftr&password=rapidftr',{:content_type => 'application/x-www-form-urlencoded'}
      RestClient.put 'http://127.0.0.1:5984/_config/admins/test_user', '"test_password"',{:cookies => @auth_response.cookies}
    end

    after :each do
      RestClient.delete 'http://127.0.0.1:5984/_config/admins/test_user',{:cookies => @auth_response.cookies}
    end

    it "should authenticate the user based on user credentials" do
      response = Replication.authenticate_with_internal_couch_users("test_user", "test_password")
      response.cookies.should_not be_nil
    end

    it "should raise exception for invalid credentials" do
      lambda{Replication.authenticate_with_internal_couch_users("test_user", "wrong_password")}.should(raise_error(RestClient::Unauthorized))
    end
  end

  ################# NOTE #################
  ##  sleep 1 is required before every  ##
  ##    destroy & restart_replication   ##
  ##  without that RestClient::Conflict ##
  ##      errors are being thrown       ##
  ################ THANKS ################

  describe 'configuration' do
    before :each do
      @source = "rapidftr_child_#{Rails.env}"
      @target = "http://localhost:5984/replication_test/"

      @rep = build :replication
      @rep.stub! :target => @target
      @rep["_id"] = 'test-replication-id'
      @rep.start_replication
      sleep 1
    end

    it 'should configure push' do
      doc = REPLICATION_DB.get @rep.push_id
      {}.merge(doc).should include "source" => @source, "target" => @target, "rapidftr_ref_id" => @rep["_id"]
    end

    it 'should configure pull' do
      doc = REPLICATION_DB.get @rep.pull_id
      {}.merge(doc).should include "source" => @target, "target" => @source, "rapidftr_ref_id" => @rep["_id"]
    end

    it 'should unconfigure push' do
      @rep.stop_replication
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @source && doc['target'] == @target }
    end

    it 'should unconfigure pull' do
      @rep.stop_replication
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @target && doc['target'] == @source }
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.push_id).should == @rep.push_doc
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.pull_id).should == @rep.pull_doc
    end

    it 'should restart replication' do
      @rep.should_receive(:stop_replication).ordered.and_return(nil)
      @rep.should_receive(:start_replication).ordered.and_return(nil)
      @rep.restart_replication
    end
  end

  ################# NOTE #################
  ##  sleep 1 is required before every  ##
  ##    destroy & restart_replication   ##
  ##  without that RestClient::Conflict ##
  ##      errors are being thrown       ##
  ################ THANKS ################

  describe 'replication' do
    pending 'couchdb replications are sporadically failing, do we need to test couchdb itself?'

    before :each do
      @dummy_db = COUCHDB_SERVER.database! 'replication_test'
      @rep = build :replication
      @rep.stub! :target => "http://localhost:5984/replication_test"
      delete_all_docs Child.database
      delete_all_docs @dummy_db
    end

    after :each do      
      delete_all_docs Child.database
      delete_all_docs @dummy_db
      sleep 1
      @rep.destroy
      @dummy_db.delete!
    end

    describe 'replicate child records from source to target' do
      pending 'couchdb replications are sporadically failing, do we need to test couchdb itself?'

      before :each do
        @child = Child.new(:name => 'Subhas')
        @child.save!
        @rep.save!
      end

      it 'on create' do
        wait_for_doc @dummy_db, 'name', 'Subhas', true
      end

      it 'on edit' do
        @child.name = 'Akash'
        @child.save

        sleep 1
        @rep.restart_replication

        wait_for_doc @dummy_db, 'name', 'Subhas', false
        wait_for_doc @dummy_db, 'name', 'Akash', true
      end

      it 'on delete' do
        @child.destroy
        sleep 1
        @rep.restart_replication
        wait_for_doc @dummy_db, 'name', 'Subhas', false
      end
    end

    describe 'replicate child records from target to source' do
      pending 'couchdb replications are sporadically failing, do we need to test couchdb itself?'

      before :each do
        result = @dummy_db.save_doc :name => 'Akash'
        @child = @dummy_db.get result['id']
        @rep.save!
      end

      it 'on create' do
        wait_for_doc Child.database, 'name', 'Akash', true
      end

      it 'on edit' do
        @child['name'] = 'Subhas'
        @dummy_db.save_doc @child
        sleep 1
        @rep.restart_replication
        wait_for_doc Child.database, 'name', 'Subhas', true
        wait_for_doc Child.database, 'name', 'Akash', false
      end

      it 'on delete' do
        @dummy_db.delete_doc @child
        sleep 1
        @rep.restart_replication
        wait_for_doc Child.database, 'name', 'Akash', false
      end
    end
  end

  def all_docs(db = REPLICATION_DB)
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
