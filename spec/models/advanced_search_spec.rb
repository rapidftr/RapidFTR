require "spec_helper"

describe "AdvancedSearch" do
  
  describe "validation" do
    
    it "should require a search field and a search value" do
      search = AdvancedSearch.new("","")
      search.valid?.should be_false
      search.errors.on(:search_field).should == "can't be empty"
      search.errors.on(:search_value).should == "can't be empty"
      
      search = AdvancedSearch.new("name", "frank")
      search.valid?.should be_true
    end
        
    it "should not be valid if search value has more than 150 chars" do
      search = AdvancedSearch.new("name","A"*151)
      search.valid?.should be_false
      search.errors.on(:search_value).should == "is invalid"
    end
    
  end
  
end