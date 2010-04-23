require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

describe "fields/new.html.erb" do

  before :each do
    @form_section = FormSection.new "unique_id" => "basic_details"
    @suggested_field = SuggestedField.new "unique_id" => "field_1", "name"=>"A field", "description"=> "This is a field", "field"=> Field.new_text_field(:name=>"theField")
    assigns[:form_section] = @form_section
    assigns[:suggested_fields] = [@suggested_field]
    render
    @searchable_response = Hpricot(response.body)
  end

  it "should add the suggested fields list" do
    suggested_field_display = get_suggested_field_display
    suggested_field_display.at("a").inner_html.strip.should == @suggested_field.name
    suggested_field_display.inner_html.should contain @suggested_field.description
  end

  it"should render a form for each suggested field" do
    pending
    suggested_field_display = get_suggested_field_display
    suggested_field_form = suggested_field_display.at("form")
    suggested_field_form.should_not be_nil
    suggested_field_form[:action].should == formsection_fields_path(@form_section.unique_id)
    @suggested_field.field.each_pair do |key, value|
      field = suggested_field_form.at("input[@id='field_definition_#{key}'][@type='hidden']")
      field.should_not be_nil
      value = value == [] ? "" : value
      field[:value].should == value
    end
    id_of_suggested_field = suggested_field_form.at("input[@name='from_suggested_field']")
    id_of_suggested_field.should_not be_nil
    id_of_suggested_field[:value].should == @suggested_field.unique_id
    submit_button = suggested_field_form.at("input[@type='submit]")
    submit_button.should_not be_nil
    submit_button[:value].should ==  "Add " + @suggested_field.name
  end
end


def get_suggested_field_display
  suggested_fields = @searchable_response.suggested_fields_list
  suggested_fields.should_not be_nil
  suggested_field_display = suggested_fields.suggested_field_display_for @suggested_field.unique_id
  suggested_field_display.should_not be_nil
  return suggested_field_display
end
