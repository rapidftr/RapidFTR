require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch


describe "fields/index.html.erb" do

  before :each do
    @form_section = FormSectionDefinition.new "unique_id" => "basic_details"
    assigns[:form_section] = @form_section
    render
    @searchable_response = Hpricot(response.body)
  end

  it "should show the add custom field link" do
    custom_field_link = @searchable_response.add_custom_field_link
    custom_field_link.should_not be_nil
    custom_field_link[:href].should == new_formsection_fields_path(@form_section.unique_id)
  end
end
