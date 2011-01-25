require 'spec_helper'

describe PublishFormSectionController do
  before do
    fake_admin_login
  end

  it "should publish form section documents as json" do
    form_sections = [FormSection.new(:name => 'Some Name', :description => 'Some description')]
    FormSection.should_receive(:enabled_by_order).and_return(form_sections)
    get :form_sections
    response.body.should == form_sections.to_json
  end

  # Waiting for story #58 Enable / Disable fields to be played
  it "should only show fields on a form that are enabled"

end