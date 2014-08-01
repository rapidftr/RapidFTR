module RapidFTR

  module EnquiriesFormSectionSetup

    def self.build_form_sections
      return [build_enquiry_section]
    end

    def self.reset_definitions
      FormSection.all.each { |f| f.destroy  if f.form.name == Enquiry::FORM_NAME  }
      Form.all.each { |f| f.destroy if f.name == Enquiry::FORM_NAME }

      form = Form.create({name: Enquiry::FORM_NAME})
      enquiry_form_section = build_enquiry_section
      enquiry_form_section.form = form
      enquiry_form_section.save
      return true
    end

    def self.build_enquiry_section
      enquiry_fields =[
          Field.new({"type" => "text_field",
                     "display_name_all" => "Enquirer Name"
                    }),
          Field.new({"type" => "textarea",
                     "display_name_all" => "Criteria"
                    })]

      FormSection.new({"visible" => true, :order => 1,
                       :fields => enquiry_fields,
                       "name_all" => "Enquiry Criteria Form",
                       "description_all" => "Enquiry Criteria Form"
      })
    end
  end
end

