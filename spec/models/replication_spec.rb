require 'spec_helper'
require 'timeout'

describe Replication do

  REPLICATION_DB = COUCHDB_SERVER.database('_replicator')

  before :each do
    all_docs(REPLICATION_DB).each { |rep| REPLICATION_DB.delete_doc rep if rep["rapidftr_ref_id"] rescue nil }
  end

  after :each do
    all_docs(REPLICATION_DB).each { |rep| REPLICATION_DB.delete_doc rep if rep["rapidftr_ref_id"] rescue nil }
  end

  describe 'validations' do
    it 'should have host' do
      r = build :replication, :host => nil
      r.should_not be_valid
      r.errors[:host].should_not be_empty
    end

    it 'should have port' do
      r = build :replication, :port => nil
      r.should_not be_valid
      r.errors[:port].should_not be_empty
    end

    it 'should have numeric post' do
      r = build :replication, :port => 'abcd'
      r.should_not be_valid
      r.errors[:port].should_not be_empty
    end

    it 'should have db' do
      r = build :replication, :database_name => nil
      r.should_not be_valid
      r.errors[:database_name].should_not be_empty
    end
  end

  describe 'getters' do
    before :each do
      @rep = build :replication, :host => 'localhost', :port => 1234, :database_name => 'test'
    end

    it 'should generate url' do
      @rep.url.should == 'http://localhost:1234/test'
    end

    it 'should generate push document id' do
      @rep.push_id.should == 'rapidftr-child-test-to-http-localhost-1234-test'
    end

    it 'should generate pull document id' do
      @rep.pull_id.should == 'http-localhost-1234-test-to-rapidftr-child-test'
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
      @local_db = "rapidftr_child_#{Rails.env}"
      @remote_url = "http://localhost:5984/replication_test"

      @rep = create :replication, :host => 'localhost', :port => '5984', :database_name => 'replication_test'
    end

    it 'should configure push' do
      doc = REPLICATION_DB.get @rep.push_id
      {}.merge(doc).should include "source" => @local_db, "target" => @remote_url, "rapidftr_ref_id" => @rep["_id"]
    end

    it 'should configure pull' do
      doc = REPLICATION_DB.get @rep.pull_id
      {}.merge(doc).should include "source" => @remote_url, "target" => @local_db, "rapidftr_ref_id" => @rep["_id"]
    end

    it 'should unconfigure push' do
      sleep 1
      @rep.destroy
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @local_db && doc['target'] == @remote_url }
    end

    it 'should unconfigure pull' do
      sleep 1
      @rep.destroy
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @remote_url && doc['target'] == @local_db }
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.push_id).should == @rep.push_config
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.pull_id).should == @rep.pull_config
    end

    it 'should return push state' do
      @rep.stub :push_config => { '_replication_state' => 'abcd' }
      @rep.push_state.should == 'abcd'
    end

    it 'should return pull state' do
      @rep.stub :pull_config => { '_replication_state' => 'abcd' }
      @rep.pull_state.should == 'abcd'
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
    before :each do
      @dummy_db = COUCHDB_SERVER.database! 'replication_test'
      @rep = build :replication, :host => 'localhost', :port => 5984, :database_name => 'replication_test'
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

    describe 'replicate child records from here to there' do
      before :each do
        @child = Child.new(:name => 'Subhas')
        @child.save
        @rep.save
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

    describe 'replicate child records from there to here' do
      before :each do
        result = @dummy_db.save_doc :name => 'Akash'
        @child = @dummy_db.get result['id']
        @rep.save
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

  def wait_for_doc(db, prop, value, found=true, seconds=60)
    Timeout::timeout(seconds) do
      until found == all_docs(db).any? { |doc| doc[prop] == value }
        sleep 0.1
      end
    end
  end

end
