module RapidFTR

  class DbSetup

    def self.reset_default_form_section_definitions

      FormSection.all.each {|u| u.destroy }

      basic_details_fields = [
              Field.new("name" => "name", "display_name" => "Name", "type" => "text_field"),
              Field.new("name" => "age", "display_name" => "Age", "type" => "numeric_text_field"),
              Field.new("name" => "age_is", "display_name" => "Age Is", "type" => "select_box", "option_strings" => ["Approximate", "Exact"]),
              Field.new("name" => "gender", "display_name" => "Gender", "type" => "radio_button", "option_strings" => ["Male", "Female"]),
              Field.new("name" => "origin", "display_name" => "Origin", "type" => "text_field"),
              Field.new("name" => "last_known_location", "display_name" => "Last Known Location", "type" => "text_field"),
              Field.new("name" => "date_of_separation", "display_name" => "Date of Separation", "type" => "select_box", "option_strings" => ["", "1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]),
              Field.new("name" => "current_photo_key", "display_name" => "Current Photo Key", "type" => "photo_upload_box"),
              Field.new("name" => "recorded_audio", "display_name" => "Recorded Audio", "type" => "audio_upload_box")
      ]

      FormSection.create!("name" =>"Basic details", "enabled"=>true, :description => "Basic information about a child", :order=> 1, :unique_id=>"basic_details", :editable => false, :fields => basic_details_fields)

      family_details_fields = [
              Field.new("name" => "fathers_name", "display_name" => "Fathers Name", "type" => "text_field"),
              Field.new("name" => "is_father_alive", "display_name" => "Is Father Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_father", "display_name" => "Reunite With Father", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "mothers_name", "display_name" => "Mothers Name", "type" => "text_field"),
              Field.new("name" => "is_mother_alive", "display_name" => "Is Mother Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_mother", "display_name" => "Reunite With Mother", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_1_name", "display_name" => "Relative 1 Name", "type" => "text_field"),
              Field.new("name" => "relative_1_relationship", "display_name" => "Relative 1 Relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_1_alive", "display_name" => "Is Relative 1 Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_1", "display_name" => "Reunite With Relative 1", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_2_name", "display_name" => "Relative 2 Name", "type" => "text_field"),
              Field.new("name" => "relative_2_relationship", "display_name" => "Relative 2 Relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_2_alive", "display_name" => "Is Relative 2 Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_2", "display_name" => "Reunite With Relative 2", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_3_name", "display_name" => "Relative 3 Name", "type" => "text_field"),
              Field.new("name" => "relative_3_relationship", "display_name" => "Relative 3 Relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_3_alive", "display_name" => "Is Relative 3 Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_3", "display_name" => "Reunite With Relative 3", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "relative_4_name", "display_name" => "Relative 4 Name", "type" => "text_field"),
              Field.new("name" => "relative_4_relationship", "display_name" => "Relative 4 Relationship", "type" => "text_field"),
              Field.new("name" => "is_relative_4_alive", "display_name" => "Is Relative 4 Alive", "type" => "radio_button", "option_strings" => ["Yes", "No", "Unknown"]),
              Field.new("name" => "reunite_with_relative_4", "display_name" => "Reunite With Relative 4", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "married", "display_name" => "Married", "type" => "select_box", "option_strings" => ["Yes", "No"]),
              Field.new("name" => "spouse_or_partner_name", "display_name" => "Spouse or Partner Name", "type" => "text_field"),
              Field.new("name" => "no_of_children", "display_name" => "No of Children", "type" => "numeric_text_field"),
      ]

      FormSection.create!("name" =>"Family details", "enabled"=>true, :description =>"Information about a child's known family", :order=> 2, :unique_id=>"family_details", :fields => family_details_fields)


      caregiver_details_fields = [
              Field.new("name" => "caregivers_name", "display_name" => "Caregiver's Name", "type" => "text_field"),
              Field.new("name" => "occupation", "display_name" => "Occupation", "type" => "text_field"),
              Field.new("name" => "relationship_to_child", "display_name" => "Relationship to Child", "type" => "text_field"),
              Field.new("name" => "is_orphan", "display_name" => "Is Orphan?", "type" => "check_box"),
              Field.new("name" => "is_refugee", "display_name" => "Is Refugees?", "type" => "check_box"),
              Field.new("name" => "trafficked_child", "display_name" => "Trafficked child?", "type" => "check_box"),
              Field.new("name" => "in_interim_care", "display_name" => "In interim care?", "type" => "check_box"),
              Field.new("name" => "is_in_child_headed_household", "display_name" => "Is in child headed household?", "type" => "check_box"),
              Field.new("name" => "sick_or_injured", "display_name" => "Sick or injured?", "type" => "check_box"),
              Field.new("name" => "possible_physical_or_sexual_abuse", "display_name" => "Possible physical or sexual abuse?", "type" => "check_box"),
              Field.new("name" => "is_disabled", "display_name" => "Is disabled?", "type" => "check_box")
      ]

      FormSection.create!("name" =>"Caregiver details", "enabled"=>true, :description =>"Information about the child's current caregiver", :order=> 3, :unique_id=>"caregiver_details", :fields => caregiver_details_fields)

      return true
    end
  end
end

