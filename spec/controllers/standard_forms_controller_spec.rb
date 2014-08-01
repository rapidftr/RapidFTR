require 'spec_helper'

describe StandardFormsController, :type => :controller do

  describe '#index' do
  
    before :each do
      fake_admin_login
    end

    it 'should assign to @forms' do
      field1 = Field.new :name => 'field 1', :display_name => 'field_one'
      field2 = Field.new :name => 'field 2', :display_name => 'field_two'
      child_form_sections = [FormSection.new(:name => 'Basic Identity', :fields => [field1])]
      enquiry_form_sections = [FormSection.new(:name => 'Enquiry', :fields => [field2])]
      allow(RapidFTR::ChildrenFormSectionSetup).to receive(:build_form_sections).and_return(child_form_sections)
      allow(RapidFTR::EnquiriesFormSectionSetup).to receive(:build_form_sections).and_return(enquiry_form_sections)
     
      get :index
     
      expect(assigns[:forms]).to eq({child: child_form_sections, enquiry: enquiry_form_sections })
    end

  end

end
