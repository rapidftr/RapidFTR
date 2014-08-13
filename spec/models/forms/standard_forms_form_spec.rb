require 'spec_helper'

describe Forms::StandardFormsForm do
  CHILD_FORM_INDEX = 0
  ENQUIRY_FORM_INDEX = 1

  before :each do
    reset_couchdb!
  end

  describe "disabling form checkboxes" do
    it "should not disable forms by default" do
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      expect(forms[CHILD_FORM_INDEX].disabled).to be(false)
      expect(forms[ENQUIRY_FORM_INDEX].disabled).to be(false)
    end

    it "should disable already existing enquiry form" do
      create :form, name: Enquiry::FORM_NAME
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      expect(forms[ENQUIRY_FORM_INDEX].disabled).to be(true)
    end

    it "should disable already existing child form" do
      create :form, name: Child::FORM_NAME
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      expect(forms[CHILD_FORM_INDEX].disabled).to be(true)
    end
  end

  describe "disabling form section checkboxes" do
    it "should not disable child form sections by default" do
      form_section = build :form_section, name: "Basic Identity"
      allow(RapidFTR::ChildrenFormSectionSetup).to receive(:build_form_sections).and_return([form_section])
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      child_form_sections = forms[CHILD_FORM_INDEX].sections
      expect(child_form_sections.first.disabled).to be_falsey
    end

    it "should not disable enquiry form sections by default" do
      form_section = build :form_section, name: "Enquiry Criteria"
      allow(RapidFTR::EnquiriesFormSectionSetup).to receive(:build_form_sections).and_return([form_section])
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      enquiry_form_sections = forms[ENQUIRY_FORM_INDEX].sections
      expect(enquiry_form_sections.first.disabled).to be_falsey
    end

    it "should disable already existing enquiry form sections" do
      form = create :form, name: Enquiry::FORM_NAME
      form_section = RapidFTR::EnquiriesFormSectionSetup.build_form_sections.first
      form_section.form = form
      form_section.save

      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      enquiry_form_sections = forms[ENQUIRY_FORM_INDEX].sections
      expect(enquiry_form_sections.first.disabled).to be(true)
    end

    it "should disable already existing child form sections" do
      form = create :form, name: Child::FORM_NAME
      form_section = RapidFTR::ChildrenFormSectionSetup.build_form_sections.first
      form_section.form = form
      form_section.save

      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      child_form_sections = forms[CHILD_FORM_INDEX].sections
      expect(child_form_sections.first.disabled).to be(true)
    end
  end

  describe "disabling already existing fields" do
    it "should have child fields enabled by default" do
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      child_form_sections = forms[CHILD_FORM_INDEX].sections
      child_form_sections.each do |section|
        section.fields.each {|field| expect(field.disabled).to be_falsey}
      end
    end

    it "should have enquiry fields enabled by default" do
      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      enquiry_form_sections = forms[ENQUIRY_FORM_INDEX].sections
      enquiry_form_sections.each do |section|
        section.fields.each {|field| expect(field.disabled).to be_falsey}
      end
    end

    it "should disable already existing fields" do
      form = create :form, name: Child::FORM_NAME
      form_section = RapidFTR::ChildrenFormSectionSetup.build_form_sections.first
      field = form_section.fields.first
      form_section.fields = [field]
      form_section.form = form
      form_section.save

      forms = Forms::StandardFormsForm.build_from_seed_data.forms
      child_form_sections = forms[CHILD_FORM_INDEX].sections
      existing_form_section = child_form_sections.first
      existing_field = existing_form_section.fields.first
      expect(existing_field.disabled).to be(true)
      existing_form_section.fields[1..-1].each do |f|
        expect(f.disabled).to be_falsey
      end
    end
  end
end
