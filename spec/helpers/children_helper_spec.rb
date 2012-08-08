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
      child.stub :has_one_interviewer? => false, :persisted? => true
      helper.link_to_update_info(child).should =~ /^<a href=.+>and others<\/a>$/
    end
  end
  describe "field_for_display" do
    it "should return the string value where set" do
      helper.field_value_for_display("Foo").should == "Foo"
    end
    it "should return nbsp string if field is nil or 0 length" do
      helper.field_value_for_display("").should == "&nbsp;"
      helper.field_value_for_display(nil).should == "&nbsp;"
      helper.field_value_for_display([]).should == "&nbsp;"
    end
    it "should comma separate values if field value is an array" do
      helper.field_value_for_display(["A", "B", "C"]).should == "A, B, C"
    end
  end

  describe "#text_to_identify_child" do
    it "should show the child unique identifier if name is not present" do
      identifier = "georgelon12345"
      child = Child.new(:unique_identifier => identifier)
      helper.text_to_identify_child(child).should == identifier
    end

    it "should show the name if it is present" do
      name = "Ygor"
      child = Child.new(:name => name)
      helper.text_to_identify_child(child).should == name
    end

    it "should show the child unique id if name is empty" do
      unique_identifier = "AnID"
      child = Child.new(:name => "", :unique_identifier => unique_identifier)
      helper.text_to_identify_child(child).should == unique_identifier
    end
  end
end
