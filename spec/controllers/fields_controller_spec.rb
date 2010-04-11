require 'spec_helper'

def should_populate_form_section(action)
  form_section = FormSectionDefinition.new :name => "Form section 1", :unique_id=>'form_section_1'
  FormSectionDefinition.stub!(:get_by_unique_id).with(form_section.unique_id).and_return(form_section)
  get action, :formsection_id => form_section.unique_id
  assigns[:form_section].should == form_section
end

describe FieldsController do
   describe "get index" do
     it "populates the view with the selected form section"do
       should_populate_form_section(:index)
     end
   end
   describe "get new" do
     it "populates the view with the selected form section"do
       should_populate_form_section(:new)
     end
     it "populates the suggested fields" do
       suggested_fields = [SuggestedField.new, SuggestedField.new, SuggestedField.new]
       SuggestedField.stub!(:all).and_return(suggested_fields)
       get :new
       assigns[:suggested_fields].should == suggested_fields
     end
   end
end
