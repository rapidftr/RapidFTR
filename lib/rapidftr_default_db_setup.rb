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
              Field.new("name" => "current_photo_key", "type" => "photo_upload_box")
      ]

      FormSection.create!("name" =>"Basic details", "enabled"=>true, :description => "Basic information about a child", :order=> 1, :unique_id=>"basic_details", :editable => false, :fields => basic_details_fields)

      family_details_fields = [
              Field.new("name" => "fathers_name", "type" => "text_field"),
              Field.new("name" => "reunite_with_father", "type" => "select_box", "option_strings" =>["No", "Yes"]),
              Field.new("name" => "mothers_name", "type" => "text_field"),
              Field.new("name" => "reunite_with_mother", "type" => "select_box", "option_strings" =>["No", "Yes"]),
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

