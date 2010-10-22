require 'spec_helper'

def should_populate_form_section(action)
  get action, :formsection_id => @form_section.unique_id
  assigns[:form_section].should == @form_section
end

describe FieldsController do
  before :each do
    fake_admin_login
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

    before :each do
      @field = Field.new :name => "myNewField", :type=>"TEXT", :display_name => "My New Field"
      SuggestedField.stub(:mark_as_used)

    end
    it "should add the new field to the formsection" do
      FormSection.should_receive(:add_field_to_formsection).with(@form_section, @field)
      post :create, :formsection_id =>@form_section.unique_id, :field => @field
    end
    
    it "should redirect back to the fields page" do
      FormSection.stub(:add_field_to_formsection)
      post :create, :formsection_id => @form_section.unique_id, :field => @field
      response.should redirect_to(formsection_fields_path(@form_section.unique_id))
    end
    
    it "should show a flash message" do
      FormSection.stub(:add_field_to_formsection)
      post :create, :formsection_id => @form_section.unique_id, :field => @field
      response.flash[:notice].should == "Field successfully added"
    end
    
    it "should mark suggested field as used if one is supplied" do 
      FormSection.stub(:add_field_to_formsection)
      suggested_field = "this_is_my_field"
      SuggestedField.should_receive(:mark_as_used).with(suggested_field)
      post :create, :formsection_id => @form_section.unique_id, :from_suggested_field => suggested_field, :field => @field
    end
    
    it "should not mark suggested field as used if there is not one supplied" do
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.should_not_receive(:mark_as_used)
      post :create, :formsection_id => @form_section.unique_id, :field => @field
    end

    it "should use the display name to form the field name if no field name is supplied" do
      FormSection.should_receive(:add_field_to_formsection).with(anything(), {"display_name"=>"My brilliant new field", "name"=>"my_brilliant_new_field", "allow_blank_default"=>false} )
      post :create, :formsection_id =>@form_section.unique_id, :field =>{:display_name=>"My brilliant new field", :name=>""}
    end
    it "should remove non alphanum characters from field display name when using it for the field name" do
      field_display_name = "This £££i$s a@ fi1eld!"
      expected_name = "this_is_a_fi1eld"
      FormSection.should_receive(:add_field_to_formsection).with(anything(), {"display_name"=>field_display_name, "name"=>expected_name, "allow_blank_default"=>false} )
      post :create, :formsection_id =>@form_section.unique_id, :field =>{:display_name=>field_display_name, :name=>""}
    end
    
    it "should remove non alphanum characters from field display name when using it for the field name" do
      field_display_name = "This i$s a@ fi1eld!"
      expected_name = "this_is_a_fi1eld"
      FormSection.should_receive(:add_field_to_formsection).with(anything(), {"display_name"=>field_display_name, "name"=>expected_name, "allow_blank_default"=>false} )
      post :create, :formsection_id =>@form_section.unique_id, :field =>{:display_name=>field_display_name, :name=>""}
    end
    
  end

  describe "post move_up and move_down" do
    before :each do
      @formsection_id = "fred"
      @field_name = "barney"
      @form_section = FormSection.new
      FormSection.stub!(:get_by_unique_id).with(@formsection_id).and_return(@form_section)
    end
    it "should swap position of selected field with the one above it" do
      @form_section.should_receive(:move_up_field).with(@field_name)
      post :move_up, :formsection_id => @formsection_id, :field_name=> @field_name
    end
    it "should redirect back to the fields page on move_up" do
      @form_section.stub(:move_up_field)
      post :move_up, :formsection_id => @formsection_id, :field_name=> @field_name
      response.should redirect_to(formsection_fields_path(@formsection_id))
    end
    it "should swap position of selected field with the one below it" do
      @form_section.should_receive(:move_down_field).with(@field_name)
      post :move_down, :formsection_id => @formsection_id, :field_name=> @field_name
    end
    it "should redirect back to the fields page on move_down" do
      @form_section.stub(:move_down_field)
      post :move_down, :formsection_id => @formsection_id, :field_name=> @field_name
      response.should redirect_to(formsection_fields_path(@formsection_id))
    end
  end
end
