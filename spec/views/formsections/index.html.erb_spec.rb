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
  enabled_icon["class"].should include(expected_icon_class)
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
  cell = row.search("td").detect { |cell| cell.inner_html.strip == @form_section_1.description }
  cell.should_not be_nil
end

def should_have_enable_or_disable_checkbox(form_section)
  row = @searchable_response.form_section_row_for form_section.unique_id
  cell = row.search("td").detect { |cell| cell.inner_html.to_s.include? "sections_"+form_section.unique_id }
  cell.should_not be_nil
end

def should_not_have_enable_or_disable_checkbox(form_section)
  row = @searchable_response.form_section_row_for form_section.unique_id
  cell = row.search("td").detect { |cell| cell.inner_html.to_s.include? "sections_"+form_section.unique_id }
  cell.should be_nil
end

describe "form_section/index.html.erb" do

  before :each do
    @form_section_1  = FormSection.new "name" => "Basic Details", "visible"=> true, "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :perm_enabled => true
    @form_section_2  = FormSection.new "name" => "Caregiver Details", "visible"=> false, "order"=>"101", "unique_id"=> "caregiver_details"
    @form_section_3 = FormSection.new "name" => "Family Details", "visible" => true, "order"=>"20", "unique_id"=>"family_details"
    assign(:form_sections, [@form_section_1, @form_section_2, @form_section_3])
    render
    @searchable_response = Hpricot(rendered)
  end

  it "renders a table row for each form section" do
    (@searchable_response.form_section_row_for @form_section_1.unique_id).should_not be_nil
    (@searchable_response.form_section_row_for @form_section_2.unique_id).should_not be_nil
    (@searchable_response.form_section_row_for @form_section_3.unique_id).should_not be_nil
 end

  it "renders the name of each form section as a link" do
    form_section_names =  @searchable_response.form_section_names
    form_section_names.length.should == 3
    form_section_names[0].inner_html.should == "Basic Details"
    form_section_names[1].inner_html.should == "Caregiver Details"
    form_section_names[2].inner_html.should == "Family Details"
  end

  it "renders a enable icon for each form section" do
    enabled_icon_should_have_icon_class "basic_details", "tick"
    enabled_icon_should_have_icon_class "caregiver_details", "cross"
  end
  it "renders enable and disable buttons" do
    @searchable_response.to_s.include?("enable_form").should == true
    @searchable_response.to_s.include?("disable_form").should == true
  end
  it "renders the enabled status text for each form section" do
    enabled_icon_should_have_text "basic_details", "Visible"
    enabled_icon_should_have_text "caregiver_details", "Hidden"
    enabled_icon_should_have_text "family_details", "Visible"
  end
  it "renders the description text for each form section" do
    should_have_description(@form_section_1)
  end
  it "renders the enable/disable checkbox for each form section" do
    should_have_enable_or_disable_checkbox(@form_section_2)
    should_have_enable_or_disable_checkbox(@form_section_3)
    should_not_have_enable_or_disable_checkbox(@form_section_1)
  end
  it "renders the current order for each form section" do
    form_section_should_have_order(@form_section_1)
    form_section_should_have_order(@form_section_2)
    form_section_should_have_order(@form_section_3)
  end
end
