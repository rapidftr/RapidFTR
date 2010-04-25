require 'spec_helper'

def should_populate_form_section(action)
  get action, :formsection_id => @form_section.unique_id
  assigns[:form_section].should == @form_section
end

describe FieldsController do
  before :each do
    @form_section = FormSection.new :name => "Form section 1", :unique_id=>'form_section_1'
    FormSection.stub!(:get_by_unique_id).with(@form_section.unique_id).and_return(@form_section)
  end
   
   describe "get index" do
     it "populates the view with the selected form section"do
       should_populate_form_section(:index)
     end
   end
   
   describe "get new" do
     
     it "populates the view with the selected form section"do
       should_populate_form_section(:new)
     end
     
     it "populates suggested fields with all unused suggested fields" do
       suggested_fields = [SuggestedField.new, SuggestedField.new, SuggestedField.new]
       SuggestedField.stub!(:all_unused).and_return(suggested_fields)
       get :new, :formsection_id=>@form_section.unique_id
       assigns[:suggested_fields].should == suggested_fields
     end
     
   end
   
   describe "get new text field" do
     
     it "populates the view with the selected form section"do
        should_populate_form_section(:new_text_field)
      end
     
   end
  
  describe "post create" do
    
    it "should add the new field to the formsection" do
      SuggestedField.stub(:mark_as_used)
      field = Field.new :name => "myNewField", :type=>"TEXT"
      FormSection.should_receive(:add_field_to_formsection).with(@form_section, field)
      post :create, :formsection_id =>@form_section.unique_id, :field => field
    end
    
    it "should redirect back to the fields page" do
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.stub(:mark_as_used)
      post :create, :formsection_id => @form_section.unique_id
      response.should redirect_to(formsection_fields_path(@form_section.unique_id))
    end
    
    it "should show a flash message" do
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.stub(:mark_as_used)
      post :create, :formsection_id => @form_section.unique_id
      response.flash[:notice].should == "Field successfully added"
    end
    
    it "should mark suggested field as used if one is supplied" do 
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.stub(:mark_as_used)
      suggested_field = "this_is_my_field"
      SuggestedField.should_receive(:mark_as_used).with(suggested_field)
      post :create, :formsection_id => @form_section.unique_id, :from_suggested_field => suggested_field
    end
    
    it "should not mark suggested field as used if there is not is supplied" do 
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.stub(:mark_as_used)
      SuggestedField.should_not_receive(:mark_as_used)
      post :create, :formsection_id => @form_section.unique_id
    end
    
  end
end
