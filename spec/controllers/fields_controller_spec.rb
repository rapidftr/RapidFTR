require 'spec_helper'

describe FieldsController do
   describe "get index" do
     it "populate the view with the selected form section" do
      form_section = FormSectionDefinition.new :name => "Form section 1", :unique_id=>'form_section_1'
      FormSectionDefinition.stub!(:get_by_unique_id).with(form_section.unique_id).and_return(form_section)
      get :index, :formsection_id => form_section.unique_id
      assigns[:form_section].should == form_section
     end
   end
end
