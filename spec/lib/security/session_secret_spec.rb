require 'spec_helper'

module Security
  describe SessionSecret do
    before :each do
      SessionSecret.stub :env => "some_test_rails_env"
    end

    it 'should generate and save secret when not present in database' do
      SessionSecret.stub :fetch => nil, :create => "some_secret"
      SessionSecret.secret_token.should == "some_secret"
    end

    it 'should return saved secret if present in database' do
      SessionSecret.stub :fetch => "some_secret", :create => "some_other_secret"
      SessionSecret.should_not_receive(:create)
      SessionSecret.secret_token.should == "some_secret"
    end

    it 'fetch should return saved secret from CouchDB' do
      SessionSecret.stub :database => SessionSecret.database
      SessionSecret.database.should_receive(:get).with("session_secret").and_return("value" => "random_secret_2")
      SessionSecret.fetch.should == "random_secret_2"
    end

    it 'save should save secret to CouchDB' do
      SessionSecret.stub :generate => "random_secret_1", :database => SessionSecret.database
      SessionSecret.database.should_receive(:save_doc).with("_id" => "session_secret", "value" => "random_secret_1").and_return(true)
      SessionSecret.create.should == "random_secret_1"
    end

    it 'should return current rails env' do
      SessionSecret.rspec_reset
      SessionSecret.env.should == Rails.env
    end

    it 'database name should have rails env' do
      SessionSecret.stub :env => "random"
      SessionSecret.database.name.should == "rapidftr_session_secret_random"
    end

    after :each do
      COUCHDB_SERVER.database(SessionSecret.database_name).delete! rescue nil
    end

  end
end
