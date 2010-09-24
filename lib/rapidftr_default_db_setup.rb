module RapidFTR

  class DbSetup

    def self.reset_default_form_section_definitions

      FormSection.all.each {|u| u.destroy }

      basic_details_fields = [
              Field.new("name" => "name", "type" => "text_field"),
              Field.new("name" => "age", "type" => "text_field"),
              Field.new("name" => "age_is", "type" => "select_box", "option_strings" => ["Approximate", "Exact"]),
              Field.new("name" => "gender", "type" => "radio_button", "option_strings" => ["Male", "Female"]),
              Field.new("name" => "origin", "type" => "text_field"),
              Field.new("name" => "last_known_location", "type" => "text_field"),
              Field.new("name" => "date_of_separation", "type" => "select_box", "option_strings" => ["", "1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]),
              Field.new("name" => "current_photo_key", "type" => "photo_upload_box"),
              Field.new("name" => "recorded_audio", "type" => "audio_upload_box")
      ]

      FormSection.create!("name" =>"Basic details", "enabled"=>true, :description => "Basic information about a child", :order=> 1, :unique_id=>"basic_details", :editable => false, :fields => basic_details_fields)

      family_details_fields = [
              Field.new("name" => "fathers_name", "type" => "text_field"),
              Field.new("name" => "is_father_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_father", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "mothers_name", "type" => "text_field"),
              Field.new("name" => "is_mother_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_mother", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_1_name", "type" => "text_field"),
              Field.new("name" => "relative_1_relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_1_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_1", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_2_name", "type" => "text_field"),
              Field.new("name" => "relative_2_relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_2_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_2", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_3_name", "type" => "text_field"),
              Field.new("name" => "relative_3_relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_3_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_3", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_4_name", "type" => "text_field"),
              Field.new("name" => "relative_4_relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_4_alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_4", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "married", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "spouse_or_partner_name", "type" => "text_field"),
              Field.new("name" => "no_of_children", "type" => "text_field"),
      ]

      FormSection.create!("name" =>"Family details", "enabled"=>true, :description =>"Information about a child's known family", :order=> 2, :unique_id=>"family_details", :fields => family_details_fields)


      caregiver_details_fields = [
              Field.new("name" => "caregivers_name", "type" => "text_field"),
              Field.new("name" => "occupation", "type" => "text_field"),
              Field.new("name" => "relationship_to_child", "type" => "text_field"),
              Field.new("name" => "is_orphan", "type" => "check_box"),
              Field.new("name" => "is_refugee", "type" => "check_box"),
              Field.new("name" => "trafficked_child", "type" => "check_box"),
              Field.new("name" => "in_interim_care", "type" => "check_box"),
              Field.new("name" => "is_in_child_headed_household", "type" => "check_box"),
              Field.new("name" => "sick_or_injured", "type" => "check_box"),
              Field.new("name" => "possible_physical_or_sexual_abuse", "type" => "check_box"),
              Field.new("name" => "is_disabled", "type" => "check_box")
      ]

      FormSection.create!("name" =>"Caregiver details", "enabled"=>true, :description =>"Information about the child's current caregiver", :order=> 3, :unique_id=>"caregiver_details", :fields => caregiver_details_fields)

      return true
    end
  end
end

