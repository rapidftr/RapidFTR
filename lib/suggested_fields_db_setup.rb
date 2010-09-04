module RapidFTR

  class SuggestedFieldsDbSetup
    def self.create_field! name, description, field_name , field_type , options=nil
      SuggestedField.create!(
              "name"=>name,
              "unique_id"=> field_name,
              "description"=>description,
              :is_used=>false,
              "field"=> Field.new("name" => field_name, "type" => field_type, "option_strings"=>options))
    end
    def self.recreate_suggested_fields
      SuggestedField.all.each {|u| u.destroy }

      create_field!("Caregiver's name", "The name of the child's caregiver", "caregivers_name", "text_field")
      create_field!("Is an orphan", "Is the child an orphan", "is_orphan", "check_box")
      create_field!("Date of separation", "When the child was separated from his/her parents", "date_of_separation",  "select_box", ["", "1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"])
      create_field!("Gender", "The child's gender",  "gender",  "radio_button", ["Male", "Female"])
    end
  end
end
