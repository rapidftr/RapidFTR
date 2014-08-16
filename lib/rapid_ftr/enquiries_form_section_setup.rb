module RapidFTR

  module EnquiriesFormSectionSetup

    def self.build_form_sections
      return [build_enquiry_section]
    end

    def self.reset_form
      FormSection.all.each { |f| f.destroy  if f.form.name == Enquiry::FORM_NAME  }
      Form.all.each { |f| f.destroy if f.name == Enquiry::FORM_NAME }
      Form.create({name: Enquiry::FORM_NAME})
    end

    def self.reset_definitions
      form = reset_form
      enquiry_form_section = build_enquiry_section
      enquiry_form_section.form = form
      enquiry_form_section.save
      return true
    end

    def self.build_enquiry_section
      enquiry_fields =[
        Field.new({
                    "name" => "enquirer_name",
                    "type" => "text_field",
                    "display_name_all" => "Enquirer Name"
                  }),
        Field.new({
                    "name" => "criteria",
                    "type" => "textarea",
                    "display_name_all" => "Criteria"
                  })]

      FormSection.new({"visible" => true, :order => 1,
                       "unique_id" => "enquiry_criteria",
                       :fields => enquiry_fields,
                       "name_all" => "Enquiry Criteria",
                       "description_all" => "Enquiry Criteria"
      })
    end
  end
end
