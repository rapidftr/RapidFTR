require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

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

def should_have_enable_or_disable_checkbox(form_section, visible)
  row = @searchable_response.form_section_row_for form_section.unique_id
  cell = row.search("td").detect { |cell| cell.inner_html.to_s.include? "sections_"+form_section.unique_id }
  (cell.search("input").to_s.include? "checked=\"checked\"").should == visible
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
    (@searchable_response.form_section_row_for @form_section_1.unique_id).search("a.formSectionLink").should_not be_nil
    (@searchable_response.form_section_row_for @form_section_2.unique_id).search("a.formSectionLink").should_not be_nil
    (@searchable_response.form_section_row_for @form_section_3.unique_id).search("a.formSectionLink").should_not be_nil
  end

  it "renders the description text for each form section" do
    should_have_description(@form_section_1)
  end

  it "renders the enable/disable checkbox for each form section" do
    should_have_enable_or_disable_checkbox(@form_section_2, true)
    should_have_enable_or_disable_checkbox(@form_section_3, false)
    should_not_have_enable_or_disable_checkbox(@form_section_1)
  end

end
