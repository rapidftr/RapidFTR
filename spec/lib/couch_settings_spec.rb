require 'spec_helper'

describe CouchSettings do

  describe '#new_with_defaults' do
    it 'should use correct config file' do
      expect(Rails).to receive(:root).and_return(Pathname.new('/test/root'))
      expect(File).to receive(:read).with(Pathname.new('/test/root/config/couchdb.yml')).and_return('---')
      expect(CouchSettings.new_with_defaults.path).to eq(Pathname.new('/test/root/config/couchdb.yml'))
    end

    it 'should use correct Rails env' do
      ::Rails.stub :env => 'test_env'
      expect(CouchSettings.new_with_defaults.env).to eq('test_env')
    end
  end

  before :each do
    @settings = CouchSettings.new 'test_path', 'test_env', {}
  end

  describe 'defaults' do
    it { expect(@settings.host).to eq('localhost') }
    it { expect(@settings.http_port).to eq('5984') }
    it { expect(@settings.https_port).to eq('6984') }
    it { expect(@settings.db_prefix).to eq('rapidftr') }
    it { expect(@settings.db_suffix).to eq('test_env') }
    it { expect(@settings.ssl_enabled_for_rapidftr?).to eq(false) }
  end

  describe 'HTTPS' do
    it 'returns https_port when using SSL' do
      @settings.stub :ssl_enabled_for_rapidftr? => true
      expect(@settings.port).to eq(@settings.https_port)
      expect(@settings.protocol).to eq('https')
    end

    it 'returns HTTPS uri with username and password' do
      @settings.stub :username => 'test_user', :password => 'test_pass', :ssl_enabled_for_rapidftr? => true
      expect(@settings.uri.to_s).to eq('https://test_user:test_pass@localhost:6984')
    end

    xit 'should check whether SSL is enabled in CouchDB' do
    end
  end

  describe 'HTTP' do
    it 'returns http_port when not using SSL' do
      @settings.stub :ssl_enabled_for_rapidftr? => false
      expect(@settings.port).to eq(@settings.http_port)
      expect(@settings.protocol).to eq('http')
    end

    it 'returns HTTP uri with username and password' do
      @settings.stub :username => 'test_user', :password => 'test_pass', :ssl_enabled_for_rapidftr? => false
      expect(@settings.uri.to_s).to eq('http://test_user:test_pass@localhost:5984')
    end
  end

end
