require File.dirname(__FILE__) + '/../../spec_helper'

describe CouchRestRails::Tests do
  
  before :each do
    setup_foo_bars
    CouchRestRails.views_path = 'vendor/plugins/couchrest-rails/spec/mock/views'
  end
  
  after :all do
    cleanup_foo_bars
  end
  
  describe '#setup' do
    
    it 'should always use the test environment' do
      RAILS_ENV.should == CouchRestRails.test_environment
    end
    
    it 'should delete, add, push views and load fixtures for the specified database' do
      # Dirty up a db first
      CouchRestRails::Database.create('foo')
      db = CouchRest.database(@foo_db_url)
      CouchRestRails::Fixtures.load('foo')
      db.documents['rows'].size.should == 10
      
      CouchRestRails::Tests.setup('foo')
      db.documents['rows'].size.should == 11 # Includes design docs
      db.view("default/all")['rows'].size.should == 10
    end
    
    it 'should delete, add, push views and load fixtures for all databases if none are specified' do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
      
      # Dirty up dbs first
      CouchRestRails::Database.create('foo')
      CouchRestRails::Database.create('bar')
      dbf = CouchRest.database(@foo_db_url)
      dbb = CouchRest.database(@bar_db_url)
      CouchRestRails::Fixtures.load('foo')
      CouchRestRails::Fixtures.load('bar')
      (dbf.documents['rows'].size + dbb.documents['rows'].size).should == 15

      CouchRestRails::Tests.setup

      (dbf.documents['rows'].size + dbb.documents['rows'].size).should == 17 # Includes design docs
      (dbf.view("default/all")['rows'].size + dbb.view("default/all")['rows'].size).should == 15
    end
    
  end
  
  describe '#teardown' do
    
    it 'should always use the test environment' do
      RAILS_ENV.should == CouchRestRails.test_environment
    end
    
    it 'should delete the specified test database' do
      CouchRestRails::Tests.setup('foo')
      CouchRestRails::Tests.teardown('foo')
      lambda {CouchRest.get(@foo_db_url)}.should raise_error('Resource not found')
    end
    
    it 'should delete all of the test databases if none are specified' do
      CouchRestRails::Tests.setup
      CouchRestRails::Tests.teardown
      lambda {CouchRest.get(@foo_db_url)}.should raise_error('Resource not found')
      lambda {CouchRest.get(@bar_db_url)}.should raise_error('Resource not found')
    end
    
  end
    
end