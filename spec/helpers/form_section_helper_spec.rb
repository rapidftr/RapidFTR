require 'spec_helper'

describe FormSectionHelper, :type => :helper do
  it "should return create url if field is new" do
    unique_id = "unique_id"
    expect(helper.url_for_form_section_field(unique_id, Field.new)).to eq(form_section_fields_path(unique_id))
  end

  it "should return update url if field exists" do
    unique_id = "unique_id"
    field_name = "field_name"
    field = double(:new? => false, :name => field_name)
    expect(helper.url_for_form_section_field(unique_id, field)).to eq(form_section_field_path(unique_id, field_name))
  end

  it "should return create url if form_section is new" do
    form = Form.new :id => "foo"
    form_section = FormSection.new :form => form
    expect(helper.url_for_form_section(form_section, form)).to eq(form_form_sections_path(form.id))
  end

  it "should return edit url if form_section exists" do
    form_section = double(:new? => false, :unique_id => "unique_id")
    expect(helper.url_for_form_section(form_section, nil)).to eq(form_section_path(form_section.unique_id))
  end
end
