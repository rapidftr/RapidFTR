require 'spec_helper'

describe FormSectionHelper do
  it "should return create url if field is new" do
    unique_id = "unique_id"
    helper.url_for_form_section(unique_id, Field.new).should == form_section_fields_path(unique_id)
    end

  it "should return update url if field exists" do
    unique_id = "unique_id"
    field_name = "field_name"
    field = mock(:new? => false, :name => field_name)
    helper.url_for_form_section(unique_id, field).should == form_section_field_path(unique_id, field_name)
  end
end