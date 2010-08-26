require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

describe "fields/_suggested_field.html.erb" do
  describe "rendering a basic field" do 
	  before :each do
		@form_section_id = "basic_details"
		@suggested_field = SuggestedField.new "unique_id" => "field_1", "name"=>"A field", "description"=> "This is a field", "field"=> Field.new_text_field("theField")
		render :locals=> {:suggested_field => @suggested_field, :form_section_id=>@form_section_id}
		@searchable_response = Hpricot(response.body)
	  end
	
	  it "should add the suggested fields add link" do
		@searchable_response.at("input[@type='submit']")[:value].strip.should == @suggested_field.name
	  end
	
	  it"should render a form for the suggested field" do
		suggested_field_form = @searchable_response.at("form")
		suggested_field_form[:action].should == formsection_fields_path(@form_section_id)
		suggested_field_form.at("input[@id='field_type']")[:value].should==@suggested_field.field.type
		suggested_field_form.at("input[@id='field_help_text']")[:value].should==@suggested_field.field.help_text
		suggested_field_form.at("input[@id='field_name']")[:value].should==@suggested_field.field.name
	  end
	  it "should add the id of the suggested field" do
		id_of_suggested_field = @searchable_response.at("input[@name='from_suggested_field']")
		id_of_suggested_field[:value].should == @suggested_field.unique_id
	  end
  end
  describe "rendering a dropdown field" do 
	  before :each do
		@suggested_field = SuggestedField.new "field"=> Field.new_select_box("theField", ["A", "B", "C"])
		render :locals=> {:suggested_field => @suggested_field, :form_section_id=>"foo"}
		@searchable_response = Hpricot(response.body)
	  end
	  it "should add a hidden field for each option" do
		@searchable_response.at("input[@id='option_string_A']")[:value].should=="A"
		@searchable_response.at("input[@id='option_string_B']")[:value].should=="B"
		@searchable_response.at("input[@id='option_string_C']")[:value].should=="C"
	  end
  end
end
