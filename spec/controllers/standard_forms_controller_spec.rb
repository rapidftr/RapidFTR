require 'spec_helper'

describe StandardFormsController, :type => :controller do

  describe '#index' do
  
    before :each do
      fake_admin_login
    end

    it 'should assign to @form_sections ' do
      field1 = Field.new :name => 'field 1', :display_name => 'field_one'
      field2 = Field.new :name => 'field 2', :display_name => 'field_two'
      expected_form_sections = [FormSection.new(:name => 'Basic Identity', :fields => [field1, field2])]
      allow(RapidFTR::ChildrenFormSectionSetup).to receive(:form_sections).and_return(expected_form_sections)

      get :index
     
      expect(assigns[:form_sections]).to eq expected_form_sections
    end

  end

end
