module RapidFTR

  module FormSectionSetup

    def self.reset_definitions

      FormSection.all.each {|u| u.destroy }
            
      basic_identity_fields = [
        Field.new("name" => "name", "display_name" => "Name", "type" => "text_field", "editable" => false),
        Field.new("name" => "rc_id_no", "display_name" => "RC ID No.", "type" => "text_field"),
        Field.new("name" => "protection_status", "display_name" => "Protection Status", "help_text" => "A separated child is any person under the age of 18, separated from both parents or from his/her revious legal or customary primary care give, but not necessarily from other relatives. An unaccompanied child is any person who meets those criteria but is ALSO separated from his/her relatives.", "type" => "select_box", "option_strings" => ["","Unaccompanied", "Separated"]),
        Field.new("name" => "id_document", "display_name" => "Personal ID Document No.", "type" => "text_field"),
        Field.new("name" => "gender", "display_name" => "Sex", "type" => "select_box", "option_strings" => ["", "Male", "Female"]),
        Field.new("name" => "nick_name", "display_name" => "Also Known As (nickname)", "type" => "text_field"),
        Field.new("name" => "names_origin", "display_name" => "Name(s) given to child after separation?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),                		
        Field.new("name" => "dob_or_age", "display_name" => "Date of Birth / Age", "type" => "text_field"),
        Field.new("name" => "birthplace", "display_name" => "Birthplace", "type" => "text_field"),
        Field.new("name" => "nationality", "display_name" => "Nationality", "type" => "text_field"),
        Field.new("name" => "ethnicity_or_tribe", "display_name" => "Ethnic group / tribe", "type" => "text_field"),
        Field.new("name" => "languages", "display_name" => "Languages spoken", "type" => "text_field"),
        Field.new("name" => "characteristics", "display_name" => "Distinguishing Physical Characteristics", "type" => "textarea"),
        Field.new("name" => "documents", "display_name" => "Documents carried by the child", "type" => "text_field"),
        Field.new("name" => "current_photo_key", "display_name" => "Current Photo Key", "type" => "photo_upload_box"),
        Field.new("name" => "recorded_audio", "display_name" => "Recorded Audio", "type" => "audio_upload_box"),
      ]
      FormSection.create!("name" =>"Basic Identity", "enabled"=>true, :description => "Basic identity information about a separated or unaccompanied child.", :order=> 1, :unique_id=>"basic_identity", "editable"=>true, :fields => basic_identity_fields, :perm_enabled => true)

      family_details_fields = [
        Field.new("name" => "fathers_name", "display_name" => "Father's Name", "type" => "text_field"),
        Field.new("name" => "is_father_alive", "display_name" => "Is Father Alive?", "type" => "select_box", "option_strings" => ["", "Unknown", "Alive", "Dead"]),
        Field.new("name" => "father_death_details", "display_name" => "If dead, please provide details", "type" => "text_field"),              
        Field.new("name" => "mothers_name", "display_name" => "Mother's Name", "type" => "text_field"),
        Field.new("name" => "is_mother_alive", "display_name" => "Is Mother Alive?", "type" => "select_box", "option_strings" => ["", "Unknown", "Alive", "Dead"]),
        Field.new("name" => "mother_death_details", "display_name" => "If dead, please provide details", "type" => "text_field"),              
        Field.new("name" => "other_family", "display_name" => "Other persons well known to the child", "type" => "textarea"),
        Field.new("name" => "address", "display_name" => "Address of child before separation (and person with whom he/she lived)",  "help_text" => "If the child does not remember his/her address, please note other relevant information, such as descriptions of mosques, churches, schools and other landmarks.", "type" => "textarea"),
        Field.new("name" => "telephone", "display_name" => "Telephone Before Separation", "type" => "text_field"),
        Field.new("name" => "caregivers_name", "display_name" => "Caregiver's Name (if different)", "type" => "text_field"),
        Field.new("name" => "is_caregiver_alive", "display_name" => "Is Caregiver Alive?", "type" => "select_box", "option_strings" => ["Unknown", "Alive", "Dead"]),
        Field.new("name" => "other_child_1", "display_name" => "1) Sibling or other child accompanying the child", "type" => "text_field"),
        Field.new("name" => "other_child_1_relationship", "display_name" => "Relationship", "type" => "text_field"),
        Field.new("name" => "other_child_1_dob", "display_name" => "Date of Birth", "type" => "text_field"),
        Field.new("name" => "other_child_1_birthplace", "display_name" => "Birthplace", "type" => "text_field"),
        Field.new("name" => "other_child_1_address", "display_name" => "Current Address", "type" => "text_field"),
        Field.new("name" => "other_child_1_telephone", "display_name" => "Telephone", "type" => "text_field"),
        Field.new("name" => "other_child_2", "display_name" => "2) Sibling or other child accompanying the child", "type" => "text_field"),
        Field.new("name" => "other_child_2_relationship", "display_name" => "Relationship", "type" => "text_field"),
        Field.new("name" => "other_child_2_dob", "display_name" => "Date of Birth", "type" => "text_field"),
        Field.new("name" => "other_child_2_birthplace", "display_name" => "Birthplace", "type" => "text_field"),
        Field.new("name" => "other_child_2_address", "display_name" => "Current Address", "type" => "text_field"),
        Field.new("name" => "other_child_2_telephone", "display_name" => "Telephone", "type" => "text_field"),
        Field.new("name" => "other_child_3", "display_name" => "3) Sibling or other child accompanying the child", "type" => "text_field"),
        Field.new("name" => "other_child_3_relationship", "display_name" => "Relationship", "type" => "text_field"),
        Field.new("name" => "other_child_3_dob", "display_name" => "Date of Birth", "type" => "text_field"),
        Field.new("name" => "other_child_3_birthplace", "display_name" => "Birthplace", "type" => "text_field"),
        Field.new("name" => "other_child_3_address", "display_name" => "Current Address", "type" => "text_field"),
        Field.new("name" => "other_child_3_telephone", "display_name" => "Telephone", "type" => "text_field"),              
      ]
      FormSection.create!("name" =>"Family details", "enabled"=>true, :description =>"Information about a child's known family", :order=> 2, :unique_id=>"family_details", :fields => family_details_fields)

      current_arrangements_fields = [
        Field.new("name" => "care_arrangements", "display_name" => "Current Care Arrangements", "type" => "select_box", "option_strings" => ["", "Children's Center", "Other Family Member(s)", "Foster Family", "Alone", "Other"]),
        Field.new("name" => "care_arrangements_other", "display_name" => "If other, please provide details.", "type" => "text_field"),
        Field.new("name" => "care_arrangments_name", "display_name" => "Full Name", "type" => "text_field"),
        Field.new("name" => "care_arrangements_relationship", "display_name" => "Relationship To Child", "type" => "text_field"),
        Field.new("name" => "care_arrangements_knowsfamily", "display_name" => "Does the caregiver know the family of the child?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
        Field.new("name" => "care_arrangements_familyinfo", "display_name" => "Caregiver's information about child or family", "type" => "textarea"),	
        Field.new("name" => "care_arrangements_address", "display_name" => "Child's current address (of caretaker or centre)", "type" => "text_field"),              
        Field.new("name" => "care_arrangements_came_from", "display_name" => "Child Arriving From", "type" => "text_field"),
        Field.new("name" => "care_arrangements_arrival_date", "display_name" => "Arrival Date", "type" => "text_field"),              
      ]
      FormSection.create!("name" =>"Care Arrangements", "enabled"=>true, :description =>"Information about the child's current caregiver", :order=> 3, :unique_id=>"care_arrangements", :fields => current_arrangements_fields)

      separation_history_fields = [
        Field.new("name" => "separation_date", "display_name" => "Date of Separation", "type" => "text_field"),
        Field.new("name" => "separation_place", "display_name" => "Place of Separation.", "type" => "text_field"),
        Field.new("name" => "separation_details", "display_name" => "Circumstances of Separation (please provide details)", "type" => "textarea"),
        Field.new("name" => "evacuation_status", "display_name" => "Has child been evacuated?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
        Field.new("name" => "evacuation_agent", "display_name" => "If yes, through which organization?", "type" => "text_field"),
        Field.new("name" => "evacuation_from", "display_name" => "Evacuated From", "type" => "text_field"),
        Field.new("name" => "evacuation_to", "display_name" => "Evacuated To", "type" => "text_field"),
        Field.new("name" => "evacuation_date", "display_name" => "Evacuation Date", "type" => "text_field"),
        Field.new("name" => "care_arrangements_arrival_date", "display_name" => "Arrival Date", "type" => "text_field"),
      ]
      FormSection.create!("name" =>"Separation History", "enabled"=>true, :description =>"The child's separation and evacuation history.", :order=> 4, :unique_id=>"separation_history", :fields => separation_history_fields)
       
      protection_concerns_fields = [
        Field.new("name" => "concerns_chh", "display_name" => "Child Headed Household","type" => "select_box", "option_strings" => ["", "Yes", "No"]),      
    	  Field.new("name" => "concerns_disabled", "display_name" => "Disabled Child","type" => "select_box", "option_strings" => ["", "Yes", "No"]), 
    	  Field.new("name" => "concerns_medical_case", "display_name" => "Medical Case","type" => "select_box", "option_strings" => ["", "Yes", "No"]), 
    	  Field.new("name" => "concerns_street_child", "display_name" => "Street Child", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
    	  Field.new("name" => "concerns_girl_mother", "display_name" => "Girl Mother", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
    	  Field.new("name" => "concerns_vulnerable_person", "display_name" => "Living with Vulnerable Person", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
    	  Field.new("name" => "concerns_abuse_situation", "display_name" => "Girl Mother", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
    	  Field.new("name" => "concerns_other", "display_name" => "Other (please specify)", "type" => "text_field"),
    	  Field.new("name" => "concerns_further_info", "display_name" => "Further Information", "type" => "textarea"),
    	  Field.new("name" => "concerns_needs_followup", "display_name" => "Specific Follow-up Required?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
    	  Field.new("name" => "concerns_followup_details", "display_name" => "Please specify follow-up needs.", "type" => "textarea"),
      ]
      FormSection.create!("name" =>"Protection Concerns", "enabled"=>true, :description =>"", :order=> 5, :unique_id=>"protection_concerns", :fields => protection_concerns_fields)

      child_wishes_fields = [
        Field.new("name" => "wishes_name_1", "display_name" => "Person child wishes to locate - Preferred", "type" => "text_field"),      
        Field.new("name" => "wishes_telephone_1", "display_name" => "Telephone", "type" => "text_field"),      
        Field.new("name" => "wishes_address_1", "display_name" => "Last Known Address", "type" => "textarea"),
        Field.new("name" => "wishes_name_2", "display_name" => "Person child wishes to locate - Second Choice", "type" => "text_field"),      
        Field.new("name" => "wishes_telephone_2", "display_name" => "Telephone", "type" => "text_field"),      
        Field.new("name" => "wishes_address_2", "display_name" => "Last Known Address", "type" => "textarea"),
        Field.new("name" => "wishes_name_3", "display_name" => "Person child wishes to locate - Third Choice", "type" => "text_field"),      
        Field.new("name" => "wishes_telephone_3", "display_name" => "Telephone", "type" => "text_field"),
        Field.new("name" => "wishes_address_3", "display_name" => "Last Known Address", "type" => "textarea"),
        Field.new("name" => "wishes_contacted", "display_name" => "Has the child heard from / been in contact with any relatives?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),
        Field.new("name" => "wishes_contacted_details", "display_name" => "Please give details", "type" => "textarea"),
        Field.new("name" => "wishes_wants_contact", "display_name" => "Does child want to be reunited with family?", "type" => "select_box", "option_strings" => ["", "Yes, as soon as possible", "Yes, later", "No"]),
        Field.new("name" => "wishes_contacted_details", "display_name" => "Please explain why", "type" => "textarea"),
      ]
      FormSection.create!("name" =>"Childs Wishes", "enabled"=>true, :description =>"", :order=> 6, :unique_id=>"childs_wishes", :fields => child_wishes_fields)
              
      other_org_fields = [
        Field.new("name" => "other_org_interview_status", "display_name" => "Has the child been interviewed by another organization?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "other_org_name", "display_name" => "Name of Organzation", "type" => "text_field"),      
        Field.new("name" => "other_org_place", "display_name" => "Place of Interview", "type" => "text_field"),      
        Field.new("name" => "other_org_country", "display_name" => "Country", "type" => "text_field"),      
        Field.new("name" => "other_org_date", "display_name" => "Date", "type" => "text_field"),      
        Field.new("name" => "orther_org_reference_no", "display_name" => "Reference No. given to child by other organization","type" => "text_field"),
      ]
	    FormSection.create!("name" =>"Other Interviews", "enabled"=>true, :description =>"", :order=> 7, :unique_id=>"other_interviews", :fields => other_org_fields)              
      
      other_tracing_info_fields = [
        Field.new("name" => "additional_tracing_info", "display_name" => "Additional Info That Could Help In Tracing?", "help_text" => "Such as key persons/location in the life of the child who/which might provide information about the location of the sought family -- e.g. names of religious leader, market place, etc. Please ask the child where he/she thinks relatives and siblings might be, and if the child is in contact with any family friends. Include any useful information the caregiver provides.", "type" => "textarea"), 
      ]	            	  
      FormSection.create!("name" =>"Other Tracing Info", "enabled"=>true, :description =>"", :order=> 8, :unique_id=>"other_tracing_info", :fields => other_tracing_info_fields)   	            	            
    	   
      interview_details_fields = [   	   
        Field.new("name" => "disclosure_public_name", "display_name" => "Does Child/Caregiver agree to share name on posters/radio/Internet?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "disclosure_public_photo", "display_name" => "Photo?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "disclosure_public_relatives", "display_name" => "Names of Relatives?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "disclosure_other_orgs", "display_name" => "Does Child/Caregiver agree to share collected information with other organizations?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "disclosure_authorities", "display_name" => "The authorities?", "type" => "select_box", "option_strings" => ["", "Yes", "No"]),  
        Field.new("name" => "disclosure_deny_details", "display_name" => "If child does not agree, specify what cannot be shared and why.", "type" => "textarea"),  
        Field.new("name" => "interview_place", "display_name" => "Place of Interview", "type" => "text_field"),      
        Field.new("name" => "interview_date", "display_name" => "Date", "type" => "text_field"),      
        Field.new("name" => "interview_subject", "display_name" => "Information Obtained From", "type" => "select_box", "option_strings" => ["", "the child", "caregiver", "other"]),
        Field.new("name" => "interview_subject_details", "display_name" => "If other, please specify", "type" => "text_field"),                    
        Field.new("name" => "interviewer", "display_name" => "Name of Interviewer","type" => "text_field"),
        Field.new("name" => "interviewers_org", "display_name" => "Interviewer's Organization","type" => "text_field"),                
        Field.new("name" => "governing_org", "display_name" => "Organization in charge of tracing child's family","type" => "text_field"),
      ]	            	            
      FormSection.create!("name" =>"Interview Details", "enabled"=>true, :description =>"", :order=> 9, :unique_id=>"interview_details", :fields => interview_details_fields)   	            	            

      return true
    end
  end
end

