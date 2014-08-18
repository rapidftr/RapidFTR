module RapidFTR
  module FormSetup
    def self.default_forms
      [default_form_for(Child::FORM_NAME), default_form_for(Enquiry::FORM_NAME)]
    end

    def self.default_form_for(form_name)
      form = Form.new(:name => form_name)
      form.sections = default_sections_for form_name
      form
    end

    def self.default_sections_for(form_name)
      if form_name == Child::FORM_NAME
        RapidFTR::ChildrenFormSectionSetup.build_form_sections
      elsif form_name == Enquiry::FORM_NAME
        RapidFTR::EnquiriesFormSectionSetup.build_form_sections
      end
    end

    def self.default_fields_for(section)
      sections = default_sections_for section.form.name
      default_section = sections.find { |s| s.name == section.name }
      default_section.nil? ? [] : default_section.fields
    end
  end
end
