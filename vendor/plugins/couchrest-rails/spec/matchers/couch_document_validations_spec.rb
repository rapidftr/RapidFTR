require File.dirname(__FILE__) + '/../spec_helper'

describe Spec::Rails::Matchers do
  
  describe 'validations' do
    
    before :all do
      class CouchRestRailsTestDocumentFoo < CouchRestRails::Document 
        use_database :foo
        
        property  :something_present
        property  :something_long
        property  :something_formatted
        property  :something_numeric
        
        validates_presence_of     :something_present
        validates_length_of       :something_long, :minimum => 10, :maximum => 50
        validates_format_of       :something_formatted, :with => /[A-Z]{3}-[0-9]{3}/
        validates_numericality_of :something_numeric

      end
      @couch_foo = CouchRestRailsTestDocumentFoo.new
    end
    
    # Use lengthy matcher names so as not to interfere with 
    # rspec-on-rails-matchers plugin if present
    
    it "should have a matcher for validates_presence_of" do
      @couch_foo.should validate_couchdb_document_presence_of(:something_present)
    end
    
    it "should have a matcher for validates_numericality_of" do
      @couch_foo.should validate_couchdb_document_numericality_of(:something_numeric)
    end
    
    it "should have a matcher for validates_format_of" do
      @couch_foo.should validate_couchdb_document_format_of(:something_formatted, :with => /[A-Z]{3}-[0-9]{3}/)
    end
    
    it "should have a matcher for validates_length_of" do
      @couch_foo.should validate_couchdb_document_length_of(:something_long, :minimum => 10, :maximum => 50)
    end
    
  end
  
end