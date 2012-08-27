require File.dirname(__FILE__) + '/../../spec_helper'

describe CouchRestRails::Database do

  before :each do
    setup_foo_bars
  end
  
  after :all do
    cleanup_foo_bars
  end
  
  describe '#create' do
  
    it 'should create the specified CouchDB database for the current environment' do
      CouchRestRails::Database.create('foo')
      res = CouchRest.get(@foo_db_url)
      res['db_name'].should == @foo_db_name
    end

    it 'should do nothing and display a message if the database already exists' do
      CouchRest.database!(@foo_db_url)
      res = CouchRestRails::Database.create('foo')
      res.should =~ /already exists/i
    end
    
    it 'should create a folder to store database views' do
      res = CouchRestRails::Database.create('foo')
      File.exist?(File.join(RAILS_ROOT, CouchRestRails.views_path, 'foo', 'views')).should be_true
    end
    
    it 'should create a folder to store lucene design docs if Lucene is enabled' do
      res = CouchRestRails::Database.create('foo')
      File.exist?(File.join(RAILS_ROOT, CouchRestRails.lucene_path, 'foo', 'lucene')).should be_true
    end
    
    it 'should create all databases as defined in CouchRestRails::Document models when no argument is specified' do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
      CouchRestRails::Database.create
      dbf = CouchRest.get(@foo_db_url)
      dbf['db_name'].should == @foo_db_name
      dbb = CouchRest.get(@bar_db_url)
      dbb['db_name'].should == @bar_db_name
    end
    
    it 'should issue a warning if no CouchRestRails::Document models are using the database' do
      res = CouchRestRails::Database.create('foobar')
      res.should =~ /no CouchRestRails::Document models using/
      CouchRestRails::Database.delete('foobar')
      FileUtils.rm_rf(File.join(RAILS_ROOT, CouchRestRails.views_path, 'foobar'))
    end

  end
  
  describe "#delete" do
    
    it 'should delete the specified CouchDB database for the current environment' do
      CouchRest.database!(@foo_db_url)
      CouchRestRails::Database.delete('foo')
      lambda {CouchRest.get(@foo_db_url)}.should raise_error('Resource not found')
    end

    it 'should do nothing and display a message if the database does not exist' do
      res = CouchRestRails::Database.delete('foo')
      res.should =~ /does not exist/i
    end
    
    it 'should delete all databases as defined in CouchRestRails::Document models when no argument is specified' do
      CouchRest.database!(@foo_db_url)
      CouchRest.database!(@bar_db_url)
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
      CouchRestRails::Database.delete
      lambda {CouchRest.get(@foo_db_url)}.should raise_error('Resource not found')
      lambda {CouchRest.get(@bar_db_url)}.should raise_error('Resource not found')
    end
    
    it 'should warn if the views path for the database still exists' do
      CouchRestRails::Database.create('foo')
      res = CouchRestRails::Database.delete('foo')
      res.should =~ /views path still present/
    end
    
    it 'should warn if the Lucene path for the database still exists if Lucene is enabled' do
      CouchRestRails::Database.create('foo')
      res = CouchRestRails::Database.delete('foo')
      res.should =~ /Lucene path still present/
    end
    
  end
  
  describe '#list' do

    it 'should return a sorted array of all CouchDB databases for the application' do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
      CouchRestRails::Database.list.include?('bar').should be_true
      CouchRestRails::Database.list.include?('foo').should be_true
      CouchRestRails::Database.list.index('foo').should > CouchRestRails::Database.list.index('bar')
    end

    it 'should raise an error if a model does not have a database defined' do
      class CouchRestRailsTestDocumentNoDatabase < CouchRestRails::Document 
      end
      lambda {CouchRestRails::Database.list}.should raise_error('CouchRestRailsTestDocumentNoDatabase does not have a database defined')
    end

  end

end