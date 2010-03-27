require 'spec_helper'

describe FormSectionController do
   describe "get index" do
     it "populate the view with all the form sections" do
      expectedFormSections = [FormSection.new("Form section 1"), FormSection.new("Number 2!!")]
      FormSectionRepository.stub!(:all).and_return(expectedFormSections)
      get :index
      assigns[:form_sections].should == expectedFormSections
     end
   end
end
