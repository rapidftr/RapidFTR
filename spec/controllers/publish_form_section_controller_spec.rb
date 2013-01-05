require 'spec_helper'

describe PublishFormSectionController do

  before do
    fake_admin_login
  end

  it "should only retrieve fields on a form that are visible" do
    FormSection.should_receive(:enabled_by_order_without_hidden_fields).and_return({})
    get :form_sections
  end

  it "should publish form section documents as json" do
    form_sections = [FormSection.new(:name => 'Some Name', :description => 'Some description')]
    FormSection.stub(:enabled_by_order_without_hidden_fields).and_return(form_sections)
    
    get :form_sections
    
    returned_form_section = JSON.parse(response.body).first
    returned_form_section['name'].should == 'Some Name'
    returned_form_section['description'].should == 'Some description'
  end
end
