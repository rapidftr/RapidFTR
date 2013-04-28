require 'spec_helper'

describe CouchSettings do

  describe '#new_with_defaults' do
    it "should use correct config file" do
      Rails.should_receive(:root).and_return(Pathname.new("/test/root"))
      File.should_receive(:read).with(Pathname.new("/test/root/config/couchdb.yml")).and_return("---")
      CouchSettings.new_with_defaults.path.should == Pathname.new("/test/root/config/couchdb.yml")
    end

    it "should use correct Rails env" do
      ::Rails.stub! :env => "test_env"
      CouchSettings.new_with_defaults.env.should == "test_env"
    end
  end

  before :each do
    @settings = CouchSettings.new "test_path", "test_env", {}
  end

  describe 'defaults' do
    it { @settings.host.should == 'localhost' }
    it { @settings.http_port.should == '5984' }
    it { @settings.https_port.should == '6984' }
    it { @settings.db_prefix.should == 'rapidftr_' }
    it { @settings.db_suffix.should == '_test_env' }
    it { @settings.ssl_enabled_for_rapidftr?.should == false }
  end

  describe 'HTTPS' do
    it "returns https_port when using SSL" do
      @settings.stub! :ssl_enabled_for_rapidftr? => true
      @settings.port.should == @settings.https_port
      @settings.protocol.should == "https"
    end

    it "returns HTTPS uri with username and password" do
      @settings.stub! :username => "test_user", :password => "test_pass", :ssl_enabled_for_rapidftr? => true
      @settings.uri.to_s.should == "https://test_user:test_pass@localhost:6984"
    end

    xit "should check whether SSL is enabled in CouchDB" do
    end
  end

  describe 'HTTP' do
    it "returns http_port when not using SSL" do
      @settings.stub! :ssl_enabled_for_rapidftr? => false
      @settings.port.should == @settings.http_port
      @settings.protocol.should == "http"
    end

    it "returns HTTP uri with username and password" do
      @settings.stub! :username => "test_user", :password => "test_pass", :ssl_enabled_for_rapidftr? => false
      @settings.uri.to_s.should == "http://test_user:test_pass@localhost:5984"
    end
  end

end
