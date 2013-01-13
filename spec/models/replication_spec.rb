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
      @rep.push_id.should == 'rapidftr-child-test-to-http-localhost-1234'
    end

    it 'should generate pull document id' do
      @rep.pull_id.should == 'http-localhost-1234-to-rapidftr-child-test'
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
      @target = "http://localhost:5984/replication_test"

      @rep = build :replication
      @rep.stub! :target => @target
      @rep.save!
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
      sleep 1
      @rep.destroy
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @source && doc['target'] == @target }
    end

    it 'should unconfigure pull' do
      sleep 1
      @rep.destroy
      all_docs(REPLICATION_DB).should_not be_any { |doc| doc['source'] == @target && doc['target'] == @source }
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.push_id).should == @rep.push_doc
    end

    it 'should return push doc' do
      REPLICATION_DB.get(@rep.pull_id).should == @rep.pull_doc
    end

    it 'should return push state' do
      @rep.stub :push_doc => { '_replication_state' => 'abcd' }
      @rep.push_state.should == 'abcd'
    end

    it 'should return pull state' do
      @rep.stub :pull_doc => { '_replication_state' => 'abcd' }
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
