require File.dirname(__FILE__) + '/../spec_helper'
require 'rails_generator'
require 'rails_generator/scripts/generate'

describe 'CouchRestRails' do
  
  after :all do
    CouchRest.delete(COUCHDB_CONFIG[:full_path]) rescue nil
  end
  
  describe 'plugin installation' do
    
    before :all do
      @fake_rails_root = File.join(File.dirname(__FILE__), 'rails_root')
      FileUtils.mkdir_p(@fake_rails_root)
      FileUtils.mkdir_p("#{@fake_rails_root}/config/initializers")
    end
    
    after :all do
      FileUtils.rm_rf(@fake_rails_root)
    end
    
    it "should generate the necessary files in the host application" do
      Rails::Generator::Scripts::Generate.new.run(
        ['couchrest_rails'], :destination => @fake_rails_root)
      Dir.glob(File.join(@fake_rails_root, "**", "*.*")).map {|f| File.basename(f) }.sort.should == 
        ['couchdb.yml', 'couchdb.rb'].sort
    end
    
  end
  
  describe ".process_database_method" do
    
    before :each do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
    end
    
    it "should act on all databases if * passed as an argument" do
      res = CouchRestRails.process_database_method('*') do |db, r|
        r << db
      end
      res.should == "\nbar\nfoo\n"
    end
    
    it "should act on a single database if passed" do
      res = CouchRestRails.process_database_method('foo') do |db, r|
        r << db
      end
      res.should == "\nfoo\n"
    end
    
  end
  
end
