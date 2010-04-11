require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch


describe "fields/new.html.erb" do

  before :each do
    @form_section = FormSectionDefinition.new "unique_id" => "basic_details"
    @suggested_field = SuggestedField.new "unique_id" => "field_1", "name"=>"A field", "description"=> "This is a field"
    assigns[:form_section] = @form_section
    assigns[:suggested_fields] = [@suggested_field]
    render
    @searchable_response = Hpricot(response.body)
  end

  it "should add the suggested fields list" do
    suggested_fields = @searchable_response.suggested_fields_list
    suggested_fields.should_not be_nil
    suggested_field_display = suggested_fields.suggested_field_display_for @suggested_field.unique_id
    suggested_field_display.should_not be_nil
    suggested_field_display.at("a").inner_html.strip.should == @suggested_field.name
    suggested_field_display.inner_html.should contain @suggested_field.description
  end
end
