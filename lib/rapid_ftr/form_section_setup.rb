module RapidFTR

  module FormSectionSetup

    def self.append_locales(key, value)
      Hash[Application::LOCALES.map{|locale| ["#{key}_#{locale}", value]}]
    end

    def self.reset_definitions
      FormSection.all.each { |f| f.destroy }

      basic_identity_fields = [
        Field.new({"name" => "name",
                  "type" => "text_field", "editable" => false,
                  "highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>1)
                  }.merge!(append_locales("display_name", "Name"))),
        Field.new({"name" => "protection_status",
                  "type" => "select_box",
                  "option_strings_text_en" => "Unaccompanied\nSeparated",
                  "highlight_information" => HighlightInformation.new("highlighted" => true,"order"=>3)
                  }.merge!(append_locales("display_name", "Protection Status")
                  ).merge!(append_locales("help_text", "A separated child is any person under the age of 18, separated from both parents or from his/her previous legal or customary primary care giver, but not necessarily from other relatives. An unaccompanied child is any person who meets those criteria but is ALSO separated from his/her relatives."))),
        Field.new({"name" => "ftr_status",
                  "type" => "select_box",
                  "option_strings_text" => "Identified\nVerified\nTracing On-Going\nFamily Located Cross-Border FR Pending\nFamily Located Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid",
                  "highlight_information" => HighlightInformation.new("highlighted" => true,"order"=>4)
                  }.merge!(append_locales("display_name", "FTR Status"))),
        Field.new({"name" => "why_record_invalid",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "If 'Record Invalid', explain why?"))),
        Field.new({"name" => "id_document",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "UNHCR No."))),
        Field.new({"name" => "rc_id_no",
                  "type" => "text_field",
                  "highlight_information"=>HighlightInformation.new("highlighted"=>true,"order"=>2)
                  }.merge!(append_locales("display_name", "RC ID No."))),
        Field.new({"name" => "icrc_ref_no",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "ICRC Ref No."))),
        Field.new({"name" => "gender",
                  "type" => "select_box",
                  "option_strings_text_en" => "Male\nFemale"
                  }.merge!(append_locales("display_name", "Sex"))),
        Field.new({"name" => "nick_name",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Also Known As (nickname)"))),
        Field.new({"name" => "names_origin",
                  "type" => "select_box",
                  "option_strings_text_en" => "Yes\nNo"
                  }.merge!(append_locales("display_name", "Name(s) given to child after separation?"))),
        Field.new({"name" => "dob_or_age",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Date of Birth / Age"))),
        Field.new({"name" => "birthplace",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Birthplace"))),
        Field.new({"name" => "nationality",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Nationality"))),
        Field.new({"name" => "ethnicity_or_tribe",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Ethnic group / tribe"))),
        Field.new({"name" => "languages",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Languages spoken"))),
        Field.new({"name" => "characteristics",
                  "type" => "textarea"
                  }.merge!(append_locales("display_name", "Distinguishing Physical Characteristics"))),
        Field.new({"name" => "documents",
                  "type" => "text_field"
                  }.merge!(append_locales("display_name", "Documents carried by the child"))),
      ]
      FormSection.create!({"visible"=>true,
                          :order=> 1, :unique_id=>"basic_identity", "editable"=>true,
                          :fields => basic_identity_fields, :perm_enabled => true
                          }.merge!(append_locales("name", "Basic Identity")
                          ).merge!(append_locales("description", "Basic identity information about a separated or unaccompanied child."))
      )

      photo_audio_fields = [
          Field.new({"name" => "current_photo_key",
                    "type" => "photo_upload_box", "editable" => false
                    }.merge!(append_locales("display_name", "Current Photo Key"))),
          Field.new({"name" => "recorded_audio",
                    "type" => "audio_upload_box", "editable" => false
                    }.merge!(append_locales("display_name", "Recorded Audio"))),
      ]
      FormSection.create!({"visible"=>true,
                          :order=> 10, :unique_id=>"photos_and_audio", :fields => photo_audio_fields,
                          :perm_visible => true, "editable"=>false
                          }.merge!(append_locales("name", "Photos and Audio")
                          ).merge!(append_locales("description", "All Photo and Audio Files Associated with a Child Record")))

      unless Rails.env.test? or Rails.env.cucumber?
        family_details_fields = [
          Field.new({"name" => "fathers_name",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Father's Name"))),
          Field.new({"name" => "is_father_alive",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Is Father Alive?")
                    ).merge!(append_locales("option_strings_text", "Unknown\nAlive\nDead"))),
          Field.new({"name" => "father_death_details",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "If dead, please provide details"))),
          Field.new({"name" => "mothers_name",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Mother's Name"))),
          Field.new({"name" => "is_mother_alive",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Is Mother Alive?")
                    ).merge!(append_locales("option_strings_text", "Unknown\nAlive\nDead"))),
          Field.new({"name" => "mother_death_details",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "If dead, please provide details"))),
          Field.new({"name" => "other_family",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Other persons well known to the child"))),
          Field.new({"name" => "address",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Address of child before separation (and person with whom he/she lived)")
                    ).merge!(append_locales("help_text", "If the child does not remember his/her address, please note other relevant information, such as descriptions of mosques, churches, schools and other landmarks."))),
          Field.new({"name" => "telephone",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone Before Separation"))),
          Field.new({"name" => "caregivers_name",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Caregiver's Name (if different)"))),
          Field.new({"name" => "is_caregiver_alive",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Is Caregiver Alive?")
                    ).merge!(append_locales("option_strings_text", "Unknown\nAlive\nDead"))),
          Field.new({"name" => "other_child_1",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "1) Sibling or other child accompanying the child"))),
          Field.new({"name" => "other_child_1_relationship",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Relationship"))),
          Field.new({"name" => "other_child_1_dob",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Date of Birth"))),
          Field.new({"name" => "other_child_1_birthplace",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Birthplace"))),
          Field.new({"name" => "other_child_1_address",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Current Address"))),
          Field.new({"name" => "other_child_1_telephone",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
          Field.new({"name" => "other_child_2",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "2) Sibling or other child accompanying the child"))),
          Field.new({"name" => "other_child_2_relationship",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Relationship"))),
          Field.new({"name" => "other_child_2_dob",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Date of Birth"))),
          Field.new({"name" => "other_child_2_birthplace",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Birthplace"))),
          Field.new({"name" => "other_child_2_address",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Current Address"))),
          Field.new({"name" => "other_child_2_telephone",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
          Field.new({"name" => "other_child_3",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "3) Sibling or other child accompanying the child"))),
          Field.new({"name" => "other_child_3_relationship",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Relationship"))),
          Field.new({"name" => "other_child_3_dob",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Date of Birth"))),
          Field.new({"name" => "other_child_3_birthplace",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Birthplace"))),
          Field.new({"name" => "other_child_3_address",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Current Address"))),
          Field.new({"name" => "other_child_3_telephone",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
        ]
        FormSection.create!({"visible"=>true,
                            :order=> 2, :unique_id=>"family_details", :fields => family_details_fields
                            }.merge!(append_locales("name", "Family details")
                            ).merge!(append_locales("description", "Information about a child's known family")))

        current_arrangements_fields = [
          Field.new({"name" => "care_arrangements",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Current Care Arrangements")
                    ).merge!(append_locales("option_strings_text", "Children's Center\nOther Family Member(s)\nFoster Family\nAlone\nOther"))),
          Field.new({"name" => "care_arrangements_other",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "If other, please provide details."))),
          Field.new({"name" => "care_arrangments_name",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Full Name"))),
          Field.new({"name" => "care_arrangements_relationship",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Relationship To Child"))),
          Field.new({"name" => "care_arrangements_knowsfamily",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Does the caregiver know the family of the child?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "care_arrangements_familyinfo",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Caregiver's information about child or family"))),
          Field.new({"name" => "care_arrangements_address",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Child's current address (of caretaker or centre)"))),
          Field.new({"name" => "care_arrangements_came_from",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Child Arriving From"))),
          Field.new({"name" => "care_arrangements_arrival_date",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Arrival Date"))),
          Field.new({"name" => "care_arrangements_convoy_no",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Convoy #")))
        ]
        FormSection.create!({"visible"=>true,
                            :order=> 3, :unique_id=>"care_arrangements", :fields => current_arrangements_fields
                            }.merge!(append_locales("name", "Care Arrangements")
                            ).merge!(append_locales("description", "Information about the child's current caregiver")))

        separation_history_fields = [
          Field.new("name" => "separation_date",
                    "display_name_en" => "Date of Separation",
                    "type" => "text_field"),
          Field.new("name" => "separation_place",
                    "display_name_en" => "Place of Separation.",
                    "type" => "text_field"),
          Field.new("name" => "separation_details",
                    "display_name_en" => "Circumstances of Separation (please provide details)",
                    "type" => "textarea"),
          Field.new("name" => "evacuation_status",
                    "display_name_en" => "Has child been evacuated?",
                    "type" => "select_box",
                    "option_strings_text_en" => "Yes\nNo"),
          Field.new("name" => "evacuation_agent",
                    "display_name_en" => "If yes, through which organization?",
                    "type" => "text_field"),
          Field.new("name" => "evacuation_from",
                    "display_name_en" => "Evacuated From",
                    "type" => "text_field"),
          Field.new("name" => "evacuation_to",
                    "display_name_en" => "Evacuated To",
                    "type" => "text_field"),
          Field.new("name" => "evacuation_date",
                    "display_name_en" => "Evacuation Date",
                    "type" => "text_field"),
          Field.new("name" => "care_arrangements_arrival_date",
                    "display_name_en" => "Arrival Date",
                    "type" => "text_field"),
        ]
        FormSection.create!({"visible"=>true,
                            :order=> 4, :unique_id=>"separation_history", :fields => separation_history_fields
                            }.merge!(append_locales("name", "Separation History")
                            ).merge!(append_locales("description", "The child's separation and evacuation history.")))

        protection_concerns_fields = [
          Field.new({"name" => "concerns_chh",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Child Headed Household")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_disabled",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Disabled Child")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_medical_case",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Medical Case")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_street_child",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Street Child")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_girl_mother",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Girl Mother")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_vulnerable_person",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Living with Vulnerable Person")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_abuse_situation",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Girl Mother")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_other",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Other (please specify)"))),
      	  Field.new({"name" => "concerns_further_info",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Further Information"))),
      	  Field.new({"name" => "concerns_needs_followup",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Specific Follow-up Required?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
      	  Field.new({"name" => "concerns_followup_details",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Please specify follow-up needs."))),
        ]
        FormSection.create!({"visible"=>true, :order=> 5,
                             :unique_id=>"protection_concerns", :fields => protection_concerns_fields
                            }.merge!(append_locales("name", "Protection Concerns")
                            ).merge!(append_locales("description", "")))

        child_wishes_fields = [
          Field.new({"name" => "wishes_name_1",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Person child wishes to locate - Preferred"))),
          Field.new({"name" => "wishes_telephone_1",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
          Field.new({"name" => "wishes_address_1",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Last Known Address"))),
          Field.new({"name" => "wishes_name_2",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Person child wishes to locate - Second Choice"))),
          Field.new({"name" => "wishes_telephone_2",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
          Field.new({"name" => "wishes_address_2",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Last Known Address"))),
          Field.new({"name" => "wishes_name_3",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Person child wishes to locate - Third Choice"))),
          Field.new({"name" => "wishes_telephone_3",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Telephone"))),
          Field.new({"name" => "wishes_address_3",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Last Known Address"))),
          Field.new({"name" => "wishes_contacted",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Has the child heard from / been in contact with any relatives?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "wishes_wants_contact",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Does child want to be reunited with family?")
                    ).merge!(append_locales("option_strings_text", "Yes as soon as possible\nYes later\nNo"))),
          Field.new({"name" => "wishes_contacted_details",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Please explain why"))),
        ]
        FormSection.create!({"visible"=>true,:order=> 6,
                             :unique_id=>"childs_wishes", :fields => child_wishes_fields
                            }.merge!(append_locales("name", "Childs Wishes")
                            ).merge!(append_locales("description", "")))

        other_org_fields = [
          Field.new({"name" => "other_org_interview_status",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Has the child been interviewed by another organization?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "other_org_name",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Name of Organization"))),
          Field.new({"name" => "other_org_place",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Place of Interview"))),
          Field.new({"name" => "other_org_country",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Country"))),
          Field.new({"name" => "other_org_date",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Date"))),
          Field.new({"name" => "orther_org_reference_no",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Reference No. given to child by other organization"))),
        ]
  	    FormSection.create!({"visible"=>true, :order=> 7,
                             :unique_id=>"other_interviews", :fields => other_org_fields
                            }.merge!(append_locales("name", "Other Interviews")
                            ).merge!(append_locales("description", "")))

        other_tracing_info_fields = [
          Field.new({"name" => "additional_tracing_info",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "Additional Info That Could Help In Tracing?")
                    ).merge!(append_locales("help_text", "Such as key persons/location in the life of the child who/which might provide information about the location of the sought family -- e.g. names of religious leader, market place, etc. Please ask the child where he/she thinks relatives and siblings might be, and if the child is in contact with any family friends. Include any useful information the caregiver provides."))),
        ]
        FormSection.create!({"visible"=>true,:order=> 8,
                             :unique_id=>"other_tracing_info", :fields => other_tracing_info_fields
                            }.merge!(append_locales("name", "Other Tracing Info")
                            ).merge!(append_locales("description", "")))

        interview_details_fields = [
          Field.new({"name" => "disclosure_public_name",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Does Child/Caregiver agree to share name on posters/radio/Internet?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "disclosure_public_photo",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Photo?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "disclosure_public_relatives",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Names of Relatives?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "disclosure_other_orgs",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Does Child/Caregiver agree to share collected information with other organizations?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "disclosure_authorities",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "The authorities?")
                    ).merge!(append_locales("option_strings_text", "Yes\nNo"))),
          Field.new({"name" => "disclosure_deny_details",
                    "type" => "textarea"
                    }.merge!(append_locales("display_name", "If child does not agree, specify what cannot be shared and why."))),
          Field.new({"name" => "interview_place",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Place of Interview"))),
          Field.new({"name" => "interview_date",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Date"))),
          Field.new({"name" => "interview_subject",
                    "type" => "select_box",
                    }.merge!(append_locales("display_name", "Information Obtained From")
                    ).merge!(append_locales("option_strings_text", "the child\ncaregiver\nother"))),
          Field.new({"name" => "interview_subject_details",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "If other, please specify"))),
          Field.new({"name" => "interviewer",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Name of Interviewer"))),
          Field.new({"name" => "interviewers_org",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Interviewer's Organization"))),
          Field.new({"name" => "governing_org",
                    "type" => "text_field"
                    }.merge!(append_locales("display_name", "Organization in charge of tracing child's family"))),
        ]
        FormSection.create!({"visible"=>true, :order=> 9,
                             :unique_id=> "interview_details", :fields => interview_details_fields
                            }.merge!(append_locales("name", "Interview Details")
                            ).merge!(append_locales("description", "")))

      end

      if Rails.env.android?
        automation_form_fields =[
           Field.new({"type" => "text_field"
                     }.merge!(append_locales("display_name", "Automation TextField"))),
           Field.new({"type" => "textarea"
                     }.merge!(append_locales("display_name", "Automation TextArea"))),
           Field.new({"type" =>"check_boxes" ,
                     }.merge!(append_locales("display_name", "Automation CheckBoxes")
                     ).merge!(append_locales("option_strings_text", "Check 1\nCheck 2\nCheck 3"))) ,
           Field.new({"type" => "select_box",
                     }.merge!(append_locales("display_name", "Automation Select")
                     ).merge!(append_locales("option_strings_text", "Select 1\nSelect 2\nSelect 3"))),
           Field.new({"type" => "radio_button",
                     }.merge!(append_locales("display_name", "Automation Radio")
                     ).merge!("option_strings_text", "Radio 1\nRadio 2\nRadio 3")),
           Field.new({"type" => "numeric_field"
                     }.merge!("display_name", "Automation Number")),
           Field.new({"type" => "date_field"
                     }.merge!(append_locales("display_name", "Automation Date"))),
           Field.new({"type" => "text_field" ,"visible" =>false
                     }.merge!(append_locales("display_name", "Hidden TextField")))

        ]
        FormSection.create!({"visible" => true, :order => 11,
                             :fields => automation_form_fields
                            }.merge!(append_locales("name", "Automation Form")
                            ).merge!(append_locales("description", "Automation Form")))
      end

      return true
    end

  end
end

