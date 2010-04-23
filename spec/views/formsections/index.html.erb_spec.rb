require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

def enabled_icon_for(form_section)
  row = @searchable_response.form_section_row_for form_section
  row.should_not be_nil
  row.enabled_icon.should_not be_nil
  return row.enabled_icon
end

def enabled_icon_should_have_icon_class (form_section, expected_icon_class)
  enabled_icon = enabled_icon_for(form_section)
  enabled_icon["class"].should contain(expected_icon_class)
end

def enabled_icon_should_have_text (form_section, expected_text)
  enabled_icon = enabled_icon_for(form_section)
  enabled_icon.inner_html.strip.should == expected_text
end

def form_section_should_have_order(form_section)
  row = @searchable_response.form_section_row_for form_section.unique_id
  form_section_order = row.form_section_order
  form_section_order.should_not be_nil
  form_section_order.inner_html.strip.should == form_section.order
end

def should_have_description(form_section)
  row = @searchable_response.form_section_row_for form_section.unique_id
  cell = row.search("td").detect {|cell| cell.inner_html.strip == @form_section_1.description }
  cell.should_not be_nil
end

describe "form_section/index.html.erb" do

  before :each do
    @form_section_1  = FormSection.new "name" => "Basic Details", "enabled"=> "true" , "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details"
    @form_section_2  = FormSection.new "name" => "Caregiver Details", "enabled"=> "false", "order"=>"101", "unique_id"=> "caregiver_details"

    assigns[:form_sections] = [@form_section_1, @form_section_2]
    render
    @searchable_response = Hpricot(response.body)
  end

  it "renders a table row for each form section" do
    (@searchable_response.form_section_row_for @form_section_1.unique_id).should_not be_nil
    (@searchable_response.form_section_row_for @form_section_2.unique_id).should_not be_nil
  end

  it "renders the name of each form section as a link" do
    form_section_names =  @searchable_response.form_section_names
    form_section_names.length.should == 2
    form_section_names[0].inner_html.should == "Basic Details"
    form_section_names[1].inner_html.should == "Caregiver Details"
  end

  it "renders a enable icon for each form section" do
    enabled_icon_should_have_icon_class "basic_details" ,"tick"
    enabled_icon_should_have_icon_class "caregiver_details" ,"cross"
  end
  it "renders the enabled status text for each form section" do
    enabled_icon_should_have_text "basic_details" ,"Enabled"
    enabled_icon_should_have_text "caregiver_details" ,"Disabled"
  end
  it "renders the description text for each form section"do
    should_have_description(@form_section_1)
  end
  it "renders the current order for each form section"do
    form_section_should_have_order(@form_section_1)
    form_section_should_have_order(@form_section_2)
  end
  it "renders the manage fields link for each form section" do
    form_section = @form_section_1
    row = @searchable_response.form_section_row_for form_section.unique_id
    manage_field_link = row.manage_fields_link
    manage_field_link.should_not be_nil
    manage_field_link.inner_html.strip.should == "Manage Fields"
    manage_field_link['href'].should == formsection_fields_path(form_section.unique_id)
  end
end
