module RapidFTR

  module SuggestedFieldsSetup
    def self.create_field! display_name, help_text, name , field_type , options=nil
      SuggestedField.create!(
              "display_name" => display_name,
              "unique_id" => name,
              "help_text" => help_text,
              :is_used=>false,
              "field"=> Field.new("name" => name, "help_text" => help_text, "display_name" => display_name,
                                  "type" => field_type, "option_strings_text" => options ))
    end
    def self.reset_definitions
      SuggestedField.all.each {|u| u.destroy }

      create_field!("Caregiver's name", "The name of the child's caregiver", "caregivers_name", "text_field")
      create_field!("Is an orphan", "Is the child an orphan", "is_orphan", "check_box")
      create_field!("Date of separation", "When the child was separated from his/her parents", "date_of_separation",  "select_box", "\n1-2 weeks ago\n2-4 weeks ago\n1-6 months ago\n6 months to 1 year ago\nMore than 1 year ago")
      create_field!("Gender", "The child's gender",  "gender",  "radio_button", "Male\nFemale")
    end
  end
end
