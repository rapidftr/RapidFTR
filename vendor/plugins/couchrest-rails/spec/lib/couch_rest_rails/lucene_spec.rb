require File.dirname(__FILE__) + '/../../spec_helper'

describe CouchRestRails::Views do
  
  before :each do
    setup_foo_bars
    CouchRestRails.lucene_path = 'vendor/plugins/couchrest-rails/spec/mock/lucene'
  end
  
  after :all do
    cleanup_foo_bars
  end
  
  describe '#push' do
  
    it "should push the Lucene search in CouchRestRails.lucene_path to a design document for the specified database" do
      CouchRestRails::Database.delete('foo')
      CouchRestRails::Database.create('foo')
      CouchRestRails::Fixtures.load('foo')
      CouchRestRails::Lucene.push('foo')
      db = CouchRest.database(@foo_db_url)      
      db.get("_design/default")['fulltext'].should_not be_blank
    end
    
    it "should replace existing searches but issue a warning" do
      CouchRestRails::Database.delete('foo')
      CouchRestRails::Database.create('foo')
      CouchRestRails::Lucene.push('foo')
      res = CouchRestRails::Lucene.push('foo')
      res.should =~ /Overwriting/
    end
    
    it "should push the Lucene searches in CouchRestRails.lucene_path to a design document for all databases if * or no argument is passed" do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
      end 
      class CouchRestRailsTestDocumentBar < CouchRestRails::Document 
        use_database :bar
      end
      CouchRestRails::Tests.setup
      CouchRestRails::Lucene.push
      dbf = CouchRest.database(@foo_db_url)
      dbb = CouchRest.database(@bar_db_url)
      dbf.get("_design/default")['fulltext'].should_not be_blank
      dbb.get("_design/default")['fulltext'].should_not be_blank
    end
  
  end
  
end