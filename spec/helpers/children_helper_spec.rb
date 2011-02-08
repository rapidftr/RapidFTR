require 'spec_helper'

describe ChildrenHelper do

  #Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ChildrenHelper)
  end

  describe "#link_to_update_info" do
    it "should not show link if child has not been updated" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      child.stub!(:has_one_interviewer?).and_return(true)
      helper.link_to_update_info(child).should be_nil
    end
    
    it "should show link if child has been updated by multiple people" do
      child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
      child.stub!(:has_one_interviewer?).and_return(false)
      helper.link_to_update_info(child).should have_tag('a', :text => 'and others')
    end
  end
end
