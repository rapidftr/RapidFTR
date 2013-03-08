module RapidFTR

  module FormSectionSetup

    def self.reset_definitions
      FormSection.all.each { |f| f.destroy }

      basic_identity_fields = [
        Field.new("name" => "name", "display_name_en" => "Name", "type" => "text_field", "editable" => false,"highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>1)),
        Field.new("name" => "rc_id_no", "display_name_en" => "RC ID No.", "type" => "text_field","highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>2)),
        Field.new("name" => "protection_status", "display_name_en" => "Protection Status", "help_text_en" => "A separated child is any person under the age of 18, separated from both parents or from his/her previous legal or customary primary care giver, but not necessarily from other relatives. An unaccompanied child is any person who meets those criteria but is ALSO separated from his/her relatives.", "type" => "select_box", "option_strings_text_en" => "Unaccompanied\nSeparated","highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>3)),
        Field.new("name" => "id_document", "display_name_en" => "Personal ID Document No.", "type" => "text_field"),
        Field.new("name" => "gender", "display_name_en" => "Sex", "type" => "select_box", "option_strings_text_en" => "Male\nFemale"),
        Field.new("name" => "nick_name", "display_name_en" => "Also Known As (nickname)", "type" => "text_field"),
        Field.new("name" => "names_origin", "display_name_en" => "Name(s) given to child after separation?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
        Field.new("name" => "dob_or_age", "display_name_en" => "Date of Birth / Age", "type" => "text_field"),
        Field.new("name" => "birthplace", "display_name_en" => "Birthplace", "type" => "text_field"),
        Field.new("name" => "nationality", "display_name_en" => "Nationality", "type" => "text_field"),
        Field.new("name" => "ethnicity_or_tribe", "display_name_en" => "Ethnic group / tribe", "type" => "text_field"),
        Field.new("name" => "languages", "display_name_en" => "Languages spoken", "type" => "text_field"),
        Field.new("name" => "characteristics", "display_name_en" => "Distinguishing Physical Characteristics", "type" => "textarea"),
        Field.new("name" => "documents", "display_name_en" => "Documents carried by the child", "type" => "text_field"),
      ]
      FormSection.create!("name_en" =>"Basic Identity", "visible"=>true, "description_en" => "Basic identity information about a separated or unaccompanied child.", :order=> 1, :unique_id=>"basic_identity", "editable"=>true, :fields => basic_identity_fields, :perm_enabled => true)

      photo_audio_fields = [
          Field.new("name" => "current_photo_key", "display_name_en" => "Current Photo Key", "type" => "photo_upload_box", "editable" => false),
          Field.new("name" => "recorded_audio", "display_name_en" => "Recorded Audio", "type" => "audio_upload_box", "editable" => false),
      ]
      FormSection.create!("name_en" =>"Photos and Audio", "visible"=>true, "description_en" =>"All Photo and Audio Files Associated with a Child Record", :order=> 10, :unique_id=>"photos_and_audio", :fields => photo_audio_fields, :perm_visible => true, "editable"=>false)


      unless Rails.env.test? or Rails.env.cucumber?
        family_details_fields = [
          Field.new("name" => "fathers_name", "display_name_en" => "Father's Name", "type" => "text_field"),
          Field.new("name" => "is_father_alive", "display_name_en" => "Is Father Alive?", "type" => "select_box", "option_strings_text_en" => "Unknown\nAlive\nDead"),
          Field.new("name" => "father_death_details", "display_name_en" => "If dead, please provide details", "type" => "text_field"),
          Field.new("name" => "mothers_name", "display_name_en" => "Mother's Name", "type" => "text_field"),
          Field.new("name" => "is_mother_alive", "display_name_en" => "Is Mother Alive?", "type" => "select_box", "option_strings_text_en" => "Unknown\nAlive\nDead"),
          Field.new("name" => "mother_death_details", "display_name_en" => "If dead, please provide details", "type" => "text_field"),
          Field.new("name" => "other_family", "display_name_en" => "Other persons well known to the child", "type" => "textarea"),
          Field.new("name" => "address", "display_name_en" => "Address of child before separation (and person with whom he/she lived)",  "help_text_en" => "If the child does not remember his/her address, please note other relevant information, such as descriptions of mosques, churches, schools and other landmarks.", "type" => "textarea"),
          Field.new("name" => "telephone", "display_name_en" => "Telephone Before Separation", "type" => "text_field"),
          Field.new("name" => "caregivers_name", "display_name_en" => "Caregiver's Name (if different)", "type" => "text_field"),
          Field.new("name" => "is_caregiver_alive", "display_name_en" => "Is Caregiver Alive?", "type" => "select_box", "option_strings_text_en" => "Unknown\nAlive\nDead"),
          Field.new("name" => "other_child_1", "display_name_en" => "1) Sibling or other child accompanying the child", "type" => "text_field"),
          Field.new("name" => "other_child_1_relationship", "display_name_en" => "Relationship", "type" => "text_field"),
          Field.new("name" => "other_child_1_dob", "display_name_en" => "Date of Birth", "type" => "text_field"),
          Field.new("name" => "other_child_1_birthplace", "display_name_en" => "Birthplace", "type" => "text_field"),
          Field.new("name" => "other_child_1_address", "display_name_en" => "Current Address", "type" => "text_field"),
          Field.new("name" => "other_child_1_telephone", "display_name_en" => "Telephone", "type" => "text_field"),
          Field.new("name" => "other_child_2", "display_name_en" => "2) Sibling or other child accompanying the child", "type" => "text_field"),
          Field.new("name" => "other_child_2_relationship", "display_name_en" => "Relationship", "type" => "text_field"),
          Field.new("name" => "other_child_2_dob", "display_name_en" => "Date of Birth", "type" => "text_field"),
          Field.new("name" => "other_child_2_birthplace", "display_name_en" => "Birthplace", "type" => "text_field"),
          Field.new("name" => "other_child_2_address", "display_name_en" => "Current Address", "type" => "text_field"),
          Field.new("name" => "other_child_2_telephone", "display_name_en" => "Telephone", "type" => "text_field"),
          Field.new("name" => "other_child_3", "display_name_en" => "3) Sibling or other child accompanying the child", "type" => "text_field"),
          Field.new("name" => "other_child_3_relationship", "display_name_en" => "Relationship", "type" => "text_field"),
          Field.new("name" => "other_child_3_dob", "display_name_en" => "Date of Birth", "type" => "text_field"),
          Field.new("name" => "other_child_3_birthplace", "display_name_en" => "Birthplace", "type" => "text_field"),
          Field.new("name" => "other_child_3_address", "display_name_en" => "Current Address", "type" => "text_field"),
          Field.new("name" => "other_child_3_telephone", "display_name_en" => "Telephone", "type" => "text_field"),
        ]
        FormSection.create!("name_en" =>"Family details", "visible"=>true, "description_en" =>"Information about a child's known family", :order=> 2, :unique_id=>"family_details", :fields => family_details_fields)

        current_arrangements_fields = [
          Field.new("name" => "care__textarrangements", "display_name_en" => "Current Care Arrangements", "type" => "select_box", "option_strings_text_en" => "Children's Center\nOther Family Member(s)\nFoster Family\nAlone\nOther"),
          Field.new("name" => "care_arrangements_other", "display_name_en" => "If other, please provide details.", "type" => "text_field"),
          Field.new("name" => "care_arrangments_name", "display_name_en" => "Full Name", "type" => "text_field"),
          Field.new("name" => "care_arrangements_relationship", "display_name_en" => "Relationship To Child", "type" => "text_field"),
          Field.new("name" => "care_arrangements_knowsfamily", "display_name_en" => "Does the caregiver know the family of the child?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "care_arrangements_familyinfo", "display_name_en" => "Caregiver's information about child or family", "type" => "textarea"),
          Field.new("name" => "care_arrangements_address", "display_name_en" => "Child's current address (of caretaker or centre)", "type" => "text_field"),
          Field.new("name" => "care_arrangements_came_from", "display_name_en" => "Child Arriving From", "type" => "text_field"),
          Field.new("name" => "care_arrangements_arrival_date", "display_name_en" => "Arrival Date", "type" => "text_field"),
        ]
        FormSection.create!("name_en" =>"Care Arrangements", "visible"=>true, "description_en" =>"Information about the child's current caregiver", :order=> 3, :unique_id=>"care_arrangements", :fields => current_arrangements_fields)

        separation_history_fields = [
          Field.new("name" => "separation_date", "display_name_en" => "Date of Separation", "type" => "text_field"),
          Field.new("name" => "separation_place", "display_name_en" => "Place of Separation.", "type" => "text_field"),
          Field.new("name" => "separation_details", "display_name_en" => "Circumstances of Separation (please provide details)", "type" => "textarea"),
          Field.new("name" => "evacuation_status", "display_name_en" => "Has child been evacuated?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "evacuation_agent", "display_name_en" => "If yes, through which organization?", "type" => "text_field"),
          Field.new("name" => "evacuation_from", "display_name_en" => "Evacuated From", "type" => "text_field"),
          Field.new("name" => "evacuation_to", "display_name_en" => "Evacuated To", "type" => "text_field"),
          Field.new("name" => "evacuation_date", "display_name_en" => "Evacuation Date", "type" => "text_field"),
          Field.new("name" => "care_arrangements_arrival_date", "display_name_en" => "Arrival Date", "type" => "text_field"),
        ]
        FormSection.create!("name_en" =>"Separation History", "visible"=>true, "description_en" =>"The child's separation and evacuation history.", :order=> 4, :unique_id=>"separation_history", :fields => separation_history_fields)

        protection_concerns_fields = [
          Field.new("name" => "concerns_chh", "display_name_en" => "Child Headed Household","type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_disabled", "display_name_en" => "Disabled Child","type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_medical_case", "display_name_en" => "Medical Case","type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_street_child", "display_name_en" => "Street Child", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_girl_mother", "display_name_en" => "Girl Mother", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_vulnerable_person", "display_name_en" => "Living with Vulnerable Person", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_abuse_situation", "display_name_en" => "Girl Mother", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_other", "display_name_en" => "Other (please specify)", "type" => "text_field"),
      	  Field.new("name" => "concerns_further_info", "display_name_en" => "Further Information", "type" => "textarea"),
      	  Field.new("name" => "concerns_needs_followup", "display_name_en" => "Specific Follow-up Required?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
      	  Field.new("name" => "concerns_followup_details", "display_name_en" => "Please specify follow-up needs.", "type" => "textarea"),
        ]
        FormSection.create!("name_en" =>"Protection Concerns", "visible"=>true, "description_en" =>"", :order=> 5, :unique_id=>"protection_concerns", :fields => protection_concerns_fields)

        child_wishes_fields = [
          Field.new("name" => "wishes_name_1", "display_name_en" => "Person child wishes to locate - Preferred", "type" => "text_field"),
          Field.new("name" => "wishes_telephone_1", "display_name_en" => "Telephone", "type" => "text_field"),
          Field.new("name" => "wishes_address_1", "display_name_en" => "Last Known Address", "type" => "textarea"),
          Field.new("name" => "wishes_name_2", "display_name_en" => "Person child wishes to locate - Second Choice", "type" => "text_field"),
          Field.new("name" => "wishes_telephone_2", "display_name_en" => "Telephone", "type" => "text_field"),
          Field.new("name" => "wishes_address_2", "display_name_en" => "Last Known Address", "type" => "textarea"),
          Field.new("name" => "wishes_name_3", "display_name_en" => "Person child wishes to locate - Third Choice", "type" => "text_field"),
          Field.new("name" => "wishes_telephone_3", "display_name_en" => "Telephone", "type" => "text_field"),
          Field.new("name" => "wishes_address_3", "display_name_en" => "Last Known Address", "type" => "textarea"),
          Field.new("name" => "wishes_contacted", "display_name_en" => "Has the child heard from / been in contact with any relatives?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "wishes_contacted_details", "display_name_en" => "Please give details", "type" => "textarea"),
          Field.new("name" => "wishes_wants_contact", "display_name_en" => "Does child want to be reunited with family?", "type" => "select_box", "option_strings_text_en" => "Yes as soon as possible\nYes later\nNo"),
          Field.new("name" => "wishes_contacted_details", "display_name_en" => "Please explain why", "type" => "textarea"),
        ]
        FormSection.create!("name_en" =>"Childs Wishes", "visible"=>true, "description_en" =>"", :order=> 6, :unique_id=>"childs_wishes", :fields => child_wishes_fields)

        other_org_fields = [
          Field.new("name" => "other_org_interview_status", "display_name_en" => "Has the child been interviewed by another organization?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "other_org_name", "display_name_en" => "Name of Organization", "type" => "text_field"),
          Field.new("name" => "other_org_place", "display_name_en" => "Place of Interview", "type" => "text_field"),
          Field.new("name" => "other_org_country", "display_name_en" => "Country", "type" => "text_field"),
          Field.new("name" => "other_org_date", "display_name_en" => "Date", "type" => "text_field"),
          Field.new("name" => "orther_org_reference_no", "display_name_en" => "Reference No. given to child by other organization","type" => "text_field"),
        ]
  	    FormSection.create!("name_en" =>"Other Interviews", "visible"=>true, "description_en" =>"", :order=> 7, :unique_id=>"other_interviews", :fields => other_org_fields)

        other_tracing_info_fields = [
          Field.new("name" => "additional_tracing_info", "display_name_en" => "Additional Info That Could Help In Tracing?", "help_text_en" => "Such as key persons/location in the life of the child who/which might provide information about the location of the sought family -- e.g. names of religious leader, market place, etc. Please ask the child where he/she thinks relatives and siblings might be, and if the child is in contact with any family friends. Include any useful information the caregiver provides.", "type" => "textarea"),
        ]
        FormSection.create!("name_en" =>"Other Tracing Info", "visible"=>true, "description_en" =>"", :order=> 8, :unique_id=>"other_tracing_info", :fields => other_tracing_info_fields)

        interview_details_fields = [
          Field.new("name" => "disclosure_public_name", "display_name_en" => "Does Child/Caregiver agree to share name on posters/radio/Internet?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "disclosure_public_photo", "display_name_en" => "Photo?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "disclosure_public_relatives", "display_name_en" => "Names of Relatives?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "disclosure_other_orgs", "display_name_en" => "Does Child/Caregiver agree to share collected information with other organizations?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "disclosure_authorities", "display_name_en" => "The authorities?", "type" => "select_box", "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "disclosure_deny_details", "display_name_en" => "If child does not agree, specify what cannot be shared and why.", "type" => "textarea"),
          Field.new("name" => "interview_place", "display_name_en" => "Place of Interview", "type" => "text_field"),
          Field.new("name" => "interview_date", "display_name_en" => "Date", "type" => "text_field"),
          Field.new("name" => "interview_subject", "display_name_en" => "Information Obtained From", "type" => "select_box", "option_strings_text_en" => "the child\ncaregiver\nother"),
          Field.new("name" => "interview_subject_details", "display_name_en" => "If other, please specify", "type" => "text_field"),
          Field.new("name" => "interviewer", "display_name_en" => "Name of Interviewer","type" => "text_field"),
          Field.new("name" => "interviewers_org", "display_name_en" => "Interviewer's Organization","type" => "text_field"),
          Field.new("name" => "governing_org", "display_name_en" => "Organization in charge of tracing child's family","type" => "text_field"),
        ]
        FormSection.create!("name_en" =>"Interview Details", "visible"=>true, "description_en" =>"", :order=> 9, :unique_id=>"interview_details", :fields => interview_details_fields)

      end

      if Rails.env.android?
        automation_form_fields =[
           Field.new("display_name_en" => "Automation TextField" ,"type" => "text_field"),
           Field.new("display_name_en" => "Automation TextArea","type" => "textarea"),
           Field.new("display_name_en" => "Automation CheckBoxes", "type" =>"check_boxes" ,"option_strings_text_en" => "Check 1\nCheck 2\nCheck 3") ,
           Field.new("display_name_en" => "Automation Select", "type" => "select_box","option_strings_text_en" => "Select 1\nSelect 2\nSelect 3"),
           Field.new("display_name_en" => "Automation Radio", "type" => "radio_button","option_strings_text_en" => "Radio 1\nRadio 2\nRadio 3"),
           Field.new("display_name_en" => "Automation Number","type" => "numeric_field"),
           Field.new("display_name_en" => "Automation Date", "type" => "date_field"),
           Field.new("display_name_en" => "Hidden TextField" ,"type" => "text_field" ,"visible" =>false)

        ]
        FormSection.create!("name_en" => "Automation Form", "visible" => true, "description_en" => "Automation Form" , :order => 11, :fields => automation_form_fields)
      end

      return true
    end

  end
end

