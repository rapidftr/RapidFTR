require File.dirname(__FILE__) + '/../../spec_helper'

describe CouchRestRails::Document do
  
  test_class = class CouchRestRailsTestDocument < CouchRestRails::Document 
    use_database :foo
    
    self
  end
  
  before :each do
    @doc = test_class.new
  end
  
  it "should inherit from CouchRest::ExtendedDocument" do
    CouchRestRails::Document.ancestors.include?(CouchRest::ExtendedDocument).should be_true
  end
  
  it "should define its CouchDB connection and CouchDB database name" do
    @doc.database.name.should == "#{COUCHDB_CONFIG[:db_prefix]}foo#{COUCHDB_CONFIG[:db_suffix]}"
  end

  describe '.unadorned_database_name' do
    
    it "should return the database name without the prefix and suffix" do
      test_class.unadorned_database_name.should == 'foo'
    end
    
  end
  
end
