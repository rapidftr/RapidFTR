module RapidFTR

  module FormSectionSetup

    def self.reset_definitions
      FormSection.all.each { |f| f.destroy }
      form_sections = []
      basic_identity_fields = [
          Field.new({"name" => "name",
                     "type" => "text_field",
                     "highlight_information" => HighlightInformation.new("highlighted" => true, "order" => 1),
                     "display_name_all" => "Name"
                    }),
          Field.new({"name" => "protection_status",
                     "type" => "select_box",
                     "option_strings_text_all" => "Unaccompanied\nSeparated",
                     "highlight_information" => HighlightInformation.new("highlighted" => true, "order" => 3),
                     "display_name_all" => "Protection Status",
                     "help_text_all" => "A separated child is any person under the age of 18, separated from both parents or from his/her previous legal or customary primary care giver, but not necessarily from other relatives. An unaccompanied child is any person who meets those criteria but is ALSO separated from his/her relatives.",
                    }),
          Field.new({"name" => "ftr_status",
                     "type" => "select_box",
                     "option_strings_text" => "Identified\nVerified\nTracing On-Going\nFamily Located Cross-Border FR Pending\nFamily Located Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid",
                     "highlight_information" => HighlightInformation.new("highlighted" => true, "order" => 4),
                     "display_name_all" => "FTR Status"
                    }),
          Field.new({"name" => "why_record_invalid",
                     "type" => "text_field",
                     "display_name_all" => "If 'Record Invalid', explain why?"
                    }),
          Field.new({"name" => "id_document",
                     "type" => "text_field",
                     "display_name_all" => "UNHCR No."
                    }),
          Field.new({"name" => "rc_id_no",
                     "type" => "text_field",
                     "highlight_information" => HighlightInformation.new("highlighted" => true, "order" => 2),
                     "display_name_all" => "RC ID No."
                    }),
          Field.new({"name" => "icrc_ref_no",
                     "type" => "text_field",
                     "display_name_all" => "ICRC Ref No."
                    }),
          Field.new({"name" => "gender",
                     "type" => "select_box",
                     "option_strings_text_all" => "Male\nFemale",
                     "display_name_all" => "Sex"
                    }),
          Field.new({"name" => "nick_name",
                     "type" => "text_field",
                     "display_name_all" => "Also Known As (nickname)"
                    }),
          Field.new({"name" => "names_origin",
                     "type" => "select_box",
                     "option_strings_text_all" => "Yes\nNo",
                     "display_name_all" => "Name(s) given to child after separation?"
                    }),
          Field.new({"name" => "date_of_birth",
                     "type" => "date_field",
                     "display_name_all" => "Date of Birth (dd/mm/yyyy)"
                    }),
          Field.new({"name" => "birthplace",
                     "type" => "text_field",
                     "display_name_all" => "Birthplace"
                    }),
          Field.new({"name" => "nationality",
                     "type" => "text_field",
                     "display_name_all" => "Nationality"
                    }),
          Field.new({"name" => "ethnicity_or_tribe",
                     "type" => "text_field",
                     "display_name_all" => "Ethnic group / tribe"
                    }),
          Field.new({"name" => "languages",
                     "type" => "text_field",
                     "display_name_all" => "Languages spoken"
                    }),
          Field.new({"name" => "characteristics",
                     "type" => "textarea",
                     "display_name_all" => "Distinguishing Physical Characteristics"
                    }),
          Field.new({"name" => "documents",
                     "type" => "text_field",
                     "display_name_all" => "Documents carried by the child"
                    }),
      ]
      basic_identity_form_section = FormSection.create!({"visible" => true,
                                                         :order => 1, :unique_id => "basic_identity", "editable" => true,
                                                         :fields => basic_identity_fields,
                                                         "name_all" => "Basic Identity",
                                                         "description_all" => "Basic identity information about a separated or unaccompanied child."
                                                        })
      form_sections << basic_identity_form_section

      photo_audio_fields = [
          Field.new({"name" => "current_photo_key",
                     "type" => "photo_upload_box", "editable" => false,
                     "display_name_all" => "Current Photo Key"
                    }),
          Field.new({"name" => "recorded_audio",
                     "type" => "audio_upload_box", "editable" => false,
                     "display_name_all" => "Recorded Audio"
                    }),
      ]
      photo_audio_form_section = FormSection.create!({"visible" => true,
                                                      :order => 10, :unique_id => "photos_and_audio", :fields => photo_audio_fields,
                                                      :perm_visible => true, "editable" => false,
                                                      "name_all" => "Photos and Audio",
                                                      "description_all" => "All Photo and Audio Files Associated with a Child Record",
                                                     })
      form_sections << photo_audio_form_section

      unless Rails.env.test? or Rails.env.cucumber?
        family_details_fields = [
            Field.new({"name" => "fathers_name",
                       "type" => "text_field",
                       "display_name_all" => "Father's Name"
                      }),
            Field.new({"name" => "is_father_alive",
                       "type" => "select_box",
                       "display_name_all" => "Is Father Alive?",
                       "option_strings_text_all" => "Unknown\nAlive\nDead",
                      }),
            Field.new({"name" => "father_death_details",
                       "type" => "text_field",
                       "display_name_all" => "If dead, please provide details"
                      }),
            Field.new({"name" => "mothers_name",
                       "type" => "text_field",
                       "display_name_all" => "Mother's Name"
                      }),
            Field.new({"name" => "is_mother_alive",
                       "type" => "select_box",
                       "display_name_all" => "Is Mother Alive?",
                       "option_strings_text_all" => "Unknown\nAlive\nDead",
                      }),
            Field.new({"name" => "mother_death_details",
                       "type" => "text_field",
                       "display_name_all" => "If dead, please provide details"
                      }),
            Field.new({"name" => "other_family",
                       "type" => "textarea",
                       "display_name_all" => "Other persons well known to the child"
                      }),
            Field.new({"name" => "address",
                       "type" => "textarea",
                       "display_name_all" => "Address of child before separation (and person with whom he/she lived)",
                       "help_text_all" => "If the child does not remember his/her address, please note other relevant information, such as descriptions of mosques, churches, schools and other landmarks.",
                      }),
            Field.new({"name" => "telephone",
                       "type" => "text_field",
                       "display_name_all" => "Telephone Before Separation"
                      }),
            Field.new({"name" => "caregivers_name",
                       "type" => "text_field",
                       "display_name_all" => "Caregiver's Name (if different)"
                      }),
            Field.new({"name" => "is_caregiver_alive",
                       "type" => "select_box",
                       "display_name_all" => "Is Caregiver Alive?",
                       "option_strings_text_all" => "Unknown\nAlive\nDead",
                      }),
            Field.new({"name" => "other_child_1",
                       "type" => "text_field",
                       "display_name_all" => "1) Sibling or other child accompanying the child"
                      }),
            Field.new({"name" => "other_child_1_relationship",
                       "type" => "text_field",
                       "display_name_all" => "Relationship"
                      }),
            Field.new({"name" => "other_child_1_dob",
                       "type" => "text_field",
                       "display_name_all" => "Date of Birth"
                      }),
            Field.new({"name" => "other_child_1_birthplace",
                       "type" => "text_field",
                       "display_name_all" => "Birthplace"
                      }),
            Field.new({"name" => "other_child_1_address",
                       "type" => "text_field",
                       "display_name_all" => "Current Address"
                      }),
            Field.new({"name" => "other_child_1_telephone",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
            Field.new({"name" => "other_child_2",
                       "type" => "text_field",
                       "display_name_all" => "2) Sibling or other child accompanying the child"
                      }),
            Field.new({"name" => "other_child_2_relationship",
                       "type" => "text_field",
                       "display_name_all" => "Relationship"
                      }),
            Field.new({"name" => "other_child_2_dob",
                       "type" => "text_field",
                       "display_name_all" => "Date of Birth"
                      }),
            Field.new({"name" => "other_child_2_birthplace",
                       "type" => "text_field",
                       "display_name_all" => "Birthplace"
                      }),
            Field.new({"name" => "other_child_2_address",
                       "type" => "text_field",
                       "display_name_all" => "Current Address"
                      }),
            Field.new({"name" => "other_child_2_telephone",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
            Field.new({"name" => "other_child_3",
                       "type" => "text_field",
                       "display_name_all" => "3) Sibling or other child accompanying the child"
                      }),
            Field.new({"name" => "other_child_3_relationship",
                       "type" => "text_field",
                       "display_name_all" => "Relationship"
                      }),
            Field.new({"name" => "other_child_3_dob",
                       "type" => "text_field",
                       "display_name_all" => "Date of Birth"
                      }),
            Field.new({"name" => "other_child_3_birthplace",
                       "type" => "text_field",
                       "display_name_all" => "Birthplace"
                      }),
            Field.new({"name" => "other_child_3_address",
                       "type" => "text_field",
                       "display_name_all" => "Current Address"
                      }),
            Field.new({"name" => "other_child_3_telephone",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
        ]
        family_details_form_section = FormSection.new({"visible" => true,
                                                       :order => 2, :unique_id => "family_details", :fields => family_details_fields,
                                                       "name_all" => "Family details",
                                                       "description_all" => "Information about a child's known family",
                                                      })
        #father_death_details and mother_death_details violate validation "Display name".
        #Skip validation because this fields.
        #The validation shows now because the field validation does not rely on the new? method.
        #should fix the data or change the validation?
        family_details_form_section.create({:validate => false})
        form_sections << family_details_form_section

        current_arrangements_fields = [
            Field.new({"name" => "care_arrangements",
                       "type" => "select_box",
                       "display_name_all" => "Current Care Arrangements",
                       "option_strings_text_all" => "Children's Center\nOther Family Member(s)\nFoster Family\nAlone\nOther",
                      }),
            Field.new({"name" => "care_arrangements_other",
                       "type" => "text_field",
                       "display_name_all" => "If other, please provide details."
                      }),
            Field.new({"name" => "care_arrangments_name",
                       "type" => "text_field",
                       "display_name_all" => "Full Name"
                      }),
            Field.new({"name" => "care_arrangements_relationship",
                       "type" => "text_field",
                       "display_name_all" => "Relationship To Child"
                      }),
            Field.new({"name" => "care_arrangements_knowsfamily",
                       "type" => "select_box",
                       "display_name_all" => "Does the caregiver know the family of the child?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "care_arrangements_familyinfo",
                       "type" => "textarea",
                       "display_name_all" => "Caregiver's information about child or family"
                      }),
            Field.new({"name" => "care_arrangements_address",
                       "type" => "text_field",
                       "display_name_all" => "Child's current address (of caretaker or centre)"
                      }),
            Field.new({"name" => "care_arrangements_came_from",
                       "type" => "text_field",
                       "display_name_all" => "Child Arriving From"
                      }),
            Field.new({"name" => "care_arrangements_arrival_date",
                       "type" => "text_field",
                       "display_name_all" => "Arrival Date"
                      }),
            Field.new({"name" => "care_arrangements_convoy_no",
                       "type" => "text_field",
                       "display_name_all" => "Convoy No"
                      })
        ]
        care_arrangements_form_section = FormSection.create!({"visible" => true,
                                                              :order => 3, :unique_id => "care_arrangements", :fields => current_arrangements_fields,
                                                              "name_all" => "Care Arrangements",
                                                              "description_all" => "Information about the child's current caregiver",
                                                             })
        form_sections << care_arrangements_form_section

        separation_history_fields = [
            Field.new("name" => "separation_place",
                      "display_name_all" => "Place of Separation.",
                      "type" => "text_field"),
            Field.new("name" => "separation_details",
                      "display_name_all" => "Circumstances of Separation (please provide details)",
                      "type" => "textarea"),
            Field.new("name" => "evacuation_status",
                      "display_name_all" => "Has child been evacuated?",
                      "type" => "select_box",
                      "option_strings_text_all" => "Yes\nNo"),
            Field.new("name" => "evacuation_agent",
                      "display_name_all" => "If yes, through which organization?",
                      "type" => "text_field"),
            Field.new("name" => "evacuation_from",
                      "display_name_all" => "Evacuated From",
                      "type" => "text_field"),
            Field.new("name" => "evacuation_to",
                      "display_name_all" => "Evacuated To",
                      "type" => "text_field"),
            Field.new("name" => "evacuation_date",
                      "display_name_all" => "Evacuation Date",
                      "type" => "text_field"),
            Field.new("name" => "separation_care_arrangements_arrival_date",
                      "display_name_all" => "Arrival Date",
                      "type" => "text_field"),
        ]
        separation_history_form_section = FormSection.create!({"visible" => true,
                                                               :order => 4, :unique_id => "separation_history", :fields => separation_history_fields,
                                                               "name_all" => "Separation History",
                                                               "description_all" => "The child's separation and evacuation history.",
                                                              })
        form_sections << separation_history_form_section

        protection_concerns_fields = [
            Field.new({"name" => "concerns_chh",
                       "type" => "select_box",
                       "display_name_all" => "Child Headed Household",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_disabled",
                       "type" => "select_box",
                       "display_name_all" => "Disabled Child",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_medical_case",
                       "type" => "select_box",
                       "display_name_all" => "Medical Case",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_street_child",
                       "type" => "select_box",
                       "display_name_all" => "Street Child",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_girl_mother",
                       "type" => "select_box",
                       "display_name_all" => "Girl Mother",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_vulnerable_person",
                       "type" => "select_box",
                       "display_name_all" => "Living with Vulnerable Person",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_other",
                       "type" => "text_field",
                       "display_name_all" => "Other (please specify)"
                      }),
            Field.new({"name" => "concerns_further_info",
                       "type" => "textarea",
                       "display_name_all" => "Further Information"
                      }),
            Field.new({"name" => "concerns_needs_followup",
                       "type" => "select_box",
                       "display_name_all" => "Specific Follow-up Required?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "concerns_followup_details",
                       "type" => "textarea",
                       "display_name_all" => "Please specify follow-up needs."
                      }),
        ]
        protection_concerns_form_section = FormSection.create!({"visible" => true, :order => 5,
                                                                :unique_id => "protection_concerns", :fields => protection_concerns_fields,
                                                                "name_all" => "Protection Concerns",
                                                                "description_all" => ""
                                                               })
        form_sections << protection_concerns_form_section

        child_wishes_fields = [
            Field.new({"name" => "wishes_name_1",
                       "type" => "text_field",
                       "display_name_all" => "Person child wishes to locate - Preferred"
                      }),
            Field.new({"name" => "wishes_telephone_1",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
            Field.new({"name" => "wishes_address_1",
                       "type" => "textarea",
                       "display_name_all" => "Last Known Address"
                      }),
            Field.new({"name" => "wishes_name_2",
                       "type" => "text_field",
                       "display_name_all" => "Person child wishes to locate - Second Choice"
                      }),
            Field.new({"name" => "wishes_telephone_2",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
            Field.new({"name" => "wishes_address_2",
                       "type" => "textarea",
                       "display_name_all" => "Last Known Address"
                      }),
            Field.new({"name" => "wishes_name_3",
                       "type" => "text_field",
                       "display_name_all" => "Person child wishes to locate - Third Choice"
                      }),
            Field.new({"name" => "wishes_telephone_3",
                       "type" => "text_field",
                       "display_name_all" => "Telephone"
                      }),
            Field.new({"name" => "wishes_address_3",
                       "type" => "textarea",
                       "display_name_all" => "Last Known Address"
                      }),
            Field.new({"name" => "wishes_contacted",
                       "type" => "select_box",
                       "display_name_all" => "Has the child heard from / been in contact with any relatives?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "wishes_contacted_details",
                       "type" => "textarea",
                       "display_name_all" => "Please give details"
                      }),
            Field.new({"name" => "wishes_wants_contact",
                       "type" => "select_box",
                       "display_name_all" => "Does child want to be reunited with family?",
                       "option_strings_text_all" => "Yes as soon as possible\nYes later\nNo",
                      }),
            Field.new({"name" => "wishes_wants_contact_details",
                       "type" => "textarea",
                       "display_name_all" => "Please explain why"
                      }),
        ]
        child_wishes_form_section = FormSection.new({"visible" => true, :order => 6,
                                                     :unique_id => "childs_wishes", :fields => child_wishes_fields,
                                                     "name_all" => "Child's Wishes",
                                                     "description_all" => ""
                                                    })
        #other_child_1, other_child_2 and other_child_1 violate validation "Display Name".
        #Skip validation because this fields.
        #The validation shows now because the field validation does not rely on the new? method.
        #should fix the data or change the validation?
        child_wishes_form_section.create({:validate => false})
        form_sections << child_wishes_form_section

        other_interviews_fields = [
            Field.new({"name" => "other_org_interview_status",
                       "type" => "select_box",
                       "display_name_all" => "Has the child been interviewed by another organization?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "other_org_name",
                       "type" => "text_field",
                       "display_name_all" => "Name of Organization"
                      }),
            Field.new({"name" => "other_org_place",
                       "type" => "text_field",
                       "display_name_all" => "Place of Interview"
                      }),
            Field.new({"name" => "other_org_country",
                       "type" => "text_field",
                       "display_name_all" => "Country"
                      }),
            Field.new({"name" => "other_org_date",
                       "type" => "text_field",
                       "display_name_all" => "Date"
                      }),
            Field.new({"name" => "orther_org_reference_no",
                       "type" => "text_field",
                       "display_name_all" => "Reference No. given to child by other organization"
                      }),
        ]
        other_interviews_form_section = FormSection.create!({"visible" => true, :order => 7,
                                                             :unique_id => "other_interviews", :fields => other_interviews_fields,
                                                             "name_all" => "Other Interviews",
                                                             "description_all" => ""
                                                            })
        form_sections << other_interviews_form_section

        other_tracing_info_fields = [
            Field.new({"name" => "additional_tracing_info",
                       "type" => "textarea",
                       "display_name_all" => "Additional Info That Could Help In Tracing?",
                       "help_text_all" => "Such as key persons/location in the life of the child who/which might provide information about the location of the sought family -- e.g. names of religious leader, market place, etc. Please ask the child where he/she thinks relatives and siblings might be, and if the child is in contact with any family friends. Include any useful information the caregiver provides.",
                      }),
        ]
        other_tracing_info_form_section = FormSection.create!({"visible" => true, :order => 8,
                                                               :unique_id => "other_tracing_info", :fields => other_tracing_info_fields,
                                                               "name_all" => "Other Tracing Info",
                                                               "description_all" => ""
                                                              })
        form_sections << other_tracing_info_form_section

        interview_details_fields = [
            Field.new({"name" => "disclosure_public_name",
                       "type" => "select_box",
                       "display_name_all" => "Does Child/Caregiver agree to share name on posters/radio/Internet?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "disclosure_public_photo",
                       "type" => "select_box",
                       "display_name_all" => "Photo?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "disclosure_public_relatives",
                       "type" => "select_box",
                       "display_name_all" => "Names of Relatives?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "disclosure_other_orgs",
                       "type" => "select_box",
                       "display_name_all" => "Does Child/Caregiver agree to share collected information with other organizations?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "disclosure_authorities",
                       "type" => "select_box",
                       "display_name_all" => "The authorities?",
                       "option_strings_text_all" => "Yes\nNo",
                      }),
            Field.new({"name" => "disclosure_deny_details",
                       "type" => "textarea",
                       "display_name_all" => "If child does not agree, specify what cannot be shared and why."
                      }),
            Field.new({"name" => "interview_place",
                       "type" => "text_field",
                       "display_name_all" => "Place of Interview"
                      }),
            Field.new({"name" => "interview_date",
                       "type" => "text_field",
                       "display_name_all" => "Date"
                      }),
            Field.new({"name" => "interview_subject",
                       "type" => "select_box",
                       "display_name_all" => "Information Obtained From",
                       "option_strings_text_all" => "the child\ncaregiver\nother",
                      }),
            Field.new({"name" => "interview_subject_details",
                       "type" => "text_field",
                       "display_name_all" => "If other, please specify"
                      }),
            Field.new({"name" => "interviewer",
                       "type" => "text_field",
                       "display_name_all" => "Name of Interviewer"
                      }),
            Field.new({"name" => "interviewers_org",
                       "type" => "text_field",
                       "display_name_all" => "Interviewer's Organization"
                      }),
            Field.new({"name" => "governing_org",
                       "type" => "text_field",
                       "display_name_all" => "Organization in charge of tracing child's family"
                      }),
        ]
        interview_details_form_section = FormSection.create!({"visible" => true, :order => 9,
                                                              :unique_id => "interview_details", :fields => interview_details_fields,
                                                              "name_all" => "Interview Details",
                                                              "description_all" => ""
                                                             })
        form_sections << interview_details_form_section

      end

      if Rails.env.android?
        automation_form_fields =[
            Field.new({"type" => "text_field",
                       "display_name_all" => "Automation TextField"
                      }),
            Field.new({"type" => "textarea",
                       "display_name_all" => "Automation TextArea"
                      }),
            Field.new({"type" => "check_boxes",
                       "display_name_all" => "Automation CheckBoxes",
                       "option_strings_text_all" => "Check 1\nCheck 2\nCheck 3",
                      }),
            Field.new({"type" => "select_box",
                       "display_name_all" => "Automation Select",
                       "option_strings_text_all" => "Select 1\nSelect 2\nSelect 3",
                      }),
            Field.new({"type" => "radio_button",
                       "display_name_all" => "Automation Radio",
                       "option_strings_text_all" => "Radio 1\nRadio 2\nRadio 3",
                      }),
            Field.new({"type" => "numeric_field",
                       "display_name_all" => "Automation Number"
                      }),
            Field.new({"type" => "date_field",
                       "display_name_all" => "Automation Date"
                      }),
            Field.new({"type" => "text_field", "visible" => false,
                       "display_name_all" => "Hidden TextField"
                      })

        ]
        automation_form_form_section = FormSection.create!({"visible" => true, :order => 11,
                                                            :fields => automation_form_fields,
                                                            "name_all" => "Automation Form",
                                                            "description_all" => "Automation Form",
                                                           })
        form_sections << automation_form_form_section
      end

      Form.create({name: "Children", form_sections: form_sections})
      return true
    end

  end
end

