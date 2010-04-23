require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch


describe "fields/index.html.erb" do

  before :each do
    fields = [Field.new(:name=>"field1"), Field.new(:name=>"field2")]
    
    @form_section = FormSection.new "unique_id" => "basic_details", "fields"=>fields
    assigns[:form_section] = @form_section
    render
    @searchable_response = Hpricot(response.body)
  end

  it "should show the add custom field link" do
    custom_field_link = @searchable_response.add_custom_field_link
    custom_field_link.should_not be_nil
    custom_field_link[:href].should == new_formsection_fields_path(@form_section.unique_id)
  end
  it "should display the list of fields" do
    field_name = @form_section.fields[0].name
    fields = Hpricot(response.body).form_fields_list
    fields.should_not be_nil
    field_row = fields.form_field_for("field1")
    field_row.should_not be_nil
  end
end
