require 'spec_helper'

describe PublishFormSectionController do
  before do
    fake_admin_login
    @form_sections = [FormSection.new(:name => 'Some Name', :description => 'Some description')]
    FormSection.should_receive(:enabled_by_order).and_return(@form_sections)
  end

  it "should publish form section documents as json" do
    get :form_sections
    response.body.should == @form_sections.to_json
  end

  it "should only show fields on a form that are enabled" do
    enabled = Field.new(:name => "enabled", :type => "text_field", :display_name => "Enabled")
    disabled = Field.new(:name => "disabled", :type => "text_field", :display_name => "Disabled", :visible => false)

    @form_sections.first.fields = [enabled, disabled]

    get :form_sections

    returned_form_section = JSON.parse(response.body).first
    returned_form_section['fields'].should == [enabled]
  end

end
