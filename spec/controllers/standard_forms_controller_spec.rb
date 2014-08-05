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
      expect(assigns[:forms]).to include(child: { disabled: false, sections: child_form_sections})
      expect(assigns[:forms]).to include(enquiry: { disabled: false, sections: enquiry_form_sections})
    end

    describe "disabling form checkboxes" do
      it "should not disable forms by default" do
        get :index
        forms = assigns[:forms]
        expect(forms[:child][:disabled]).to be(false)
        expect(forms[:child][:disabled]).to be(false)
      end

      it "should disable already existing enquiry form" do
        create :form, name: Enquiry::FORM_NAME
        get :index
        forms = assigns[:forms]
        expect(forms[:enquiry][:disabled]).to be(true)
      end

      it "should disable already existing child form" do
        create :form, name: Child::FORM_NAME
        get :index
        forms = assigns[:forms]
        expect(forms[:child][:disabled]).to be(true)
      end
    end

    describe "disabling form section checkboxes" do
      it "should not disable child form sections by default" do
        form_section = build :form_section, name: "Basic Identity"
        allow(RapidFTR::ChildrenFormSectionSetup).to receive(:build_form_sections).and_return([form_section])
        get :index
        child_form_sections = assigns[:forms][:child][:sections]
        expect(child_form_sections.first[:disabled]).to be_falsey
      end

      it "should not disable enquiry form sections by default" do
        form_section = build :form_section, name: "Enquiry Criteria"
        allow(RapidFTR::EnquiriesFormSectionSetup).to receive(:build_form_sections).and_return([form_section])
        get :index
        enquiry_form_sections = assigns[:forms][:enquiry][:sections]
        expect(enquiry_form_sections.first[:disabled]).to be_falsey
      end

      it "should disable already existing enquiry form sections" do
        form = create :form, name: Enquiry::FORM_NAME
        form_section = RapidFTR::EnquiriesFormSectionSetup.build_form_sections.first
        form_section.form = form
        form_section.save

        get :index
        enquiry_form_sections = assigns[:forms][:enquiry][:sections]
        expect(enquiry_form_sections.first[:disabled]).to be(true)
      end

      it "should disable already existing child form sections" do
        form = create :form, name: Child::FORM_NAME
        form_section = RapidFTR::ChildrenFormSectionSetup.build_form_sections.first
        form_section.form = form
        form_section.save

        get :index
        child_form_sections = assigns[:forms][:child][:sections]
        expect(child_form_sections.first[:disabled]).to be(true)
      end
    end
  end
end
