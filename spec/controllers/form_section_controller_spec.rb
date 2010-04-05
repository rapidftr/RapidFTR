require 'spec_helper'

describe FormSectionController do
   describe "get index" do
     it "populate the view with all the form sections" do
      expected_form_sections = [FormSectionDefinition.new(name => "Form section 1"), FormSectionDefinition.new(name => "Form section 2")]
      FormSectionDefinition.stub!(:all).and_return(expected_form_sections)
      get :index
      assigns[:form_sections].should == expected_form_sections
     end
     it "orders the form sections by their display order" do
      expected_form_sections = [FormSectionDefinition.new(name => "Form section 1", :order=>100), FormSectionDefinition.new(name => "Form section 2", :order=>1)]
      FormSectionDefinition.stub!(:all).and_return(expected_form_sections)
      get :index
      assigns[:form_sections][0].should == expected_form_sections[1]
      assigns[:form_sections][1].should == expected_form_sections[0]

     end
   end
end
