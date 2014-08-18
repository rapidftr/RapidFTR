require 'spec_helper'

module Security
  describe SessionSecret do
    before :each do
      SessionSecret.stub :env => 'some_test_rails_env'
    end

    it 'should generate and save secret when not present in database' do
      SessionSecret.stub :fetch => nil, :create => 'some_secret'
      expect(SessionSecret.secret_token).to eq('some_secret')
    end

    it 'should return saved secret if present in database' do
      SessionSecret.stub :fetch => 'some_secret', :create => 'some_other_secret'
      expect(SessionSecret).not_to receive(:create)
      expect(SessionSecret.secret_token).to eq('some_secret')
    end

    it 'fetch should return saved secret from CouchDB' do
      SessionSecret.stub :database => SessionSecret.database
      expect(SessionSecret.database).to receive(:get).with('session_secret').and_return('value' => 'random_secret_2')
      expect(SessionSecret.fetch).to eq('random_secret_2')
    end

    it 'save should save secret to CouchDB' do
      SessionSecret.stub :generate => 'random_secret_1', :database => SessionSecret.database
      expect(SessionSecret.database).to receive(:save_doc).with('_id' => 'session_secret', 'value' => 'random_secret_1').and_return(true)
      expect(SessionSecret.create).to eq('random_secret_1')
    end

    it 'should return current rails env' do
      RSpec::Mocks.space.proxy_for(SessionSecret).reset
      expect(SessionSecret.env).to eq(Rails.env)
    end

    it 'database name should have rails env' do
      SessionSecret.stub :env => 'random'
      expect(SessionSecret.database.name).to eq('rapidftr_session_secret_random')
    end

    after :each do
      COUCHDB_SERVER.database(SessionSecret.database_name).delete! rescue nil
    end

  end
end
