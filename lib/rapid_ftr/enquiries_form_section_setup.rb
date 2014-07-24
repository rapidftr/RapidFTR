module RapidFTR

  module EnquiriesFormSectionSetup

    def self.reset_definitions
      FormSection.all.each { |f| f.destroy  if f.form.name == Enquiry::FORM_NAME  }
      Form.all.each { |f| f.destroy if f.name == Enquiry::FORM_NAME }
      form = Form.create({ name: Enquiry::FORM_NAME })

      create_enquiry_section(form)
      return true
    end

    def self.create_enquiry_section(form)
      enquiry_fields =[
          Field.new({"type" => "text_field",
                     "display_name_all" => "Enquirer Name"
                    }),
          Field.new({"type" => "textarea",
                     "display_name_all" => "Criteria"
                    })]

      FormSection.create!({"visible" => true, :order => 1,
                           :fields => enquiry_fields,
                           "name_all" => "Enquiry Criteria Form",
                           "description_all" => "Enquiry Criteria Form",
                           :form => form
                          })
    end
  end
end

