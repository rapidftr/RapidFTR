module RapidFTR
  module ChildrenFormSectionSetup
    def self.build_form_sections
      form_sections = []
      form_sections << build_basic_identity_section
      unless Rails.env.test? || Rails.env.cucumber?
        form_sections << build_interview_details_section
        form_sections << build_other_interviews_section
        form_sections << build_other_tracing_info_section
        form_sections << build_child_wishes_section
        form_sections << build_protection_concerns_section
        form_sections << build_separation_history_section
        form_sections << build_current_arrangements_section
        form_sections << build_family_details_section
      end
      form_sections << build_photo_audio_section
    end

    def self.reset_form
      FormSection.all.each { |f| f.destroy  if f.form.name == Child::FORM_NAME }
      Form.all.each { |f| f.destroy  if f.name == Child::FORM_NAME }
      Form.create(:_id => '16d784ba-0abd-4cc6-b21f-891d6a9c671d', :name => Child::FORM_NAME)
    end

    def self.reset_definitions
      form = reset_form
      build_form_sections.each do |fs|
        fs.form = form
        fs.save
      end
      true
    end

    def self.build_interview_details_section
      interview_details_fields = [
        Field.new('name' => 'disclosure_public_name',
                  'type' => 'select_box',
                  'display_name_all' => 'Does Child/Caregiver agree to share name on posters/radio/Internet?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'disclosure_public_photo',
                  'type' => 'select_box',
                  'display_name_all' => 'Photo?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'disclosure_public_relatives',
                  'type' => 'select_box',
                  'display_name_all' => 'Names of Relatives?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'disclosure_other_orgs',
                  'type' => 'select_box',
                  'display_name_all' => 'Does Child/Caregiver agree to share collected information with other organizations?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'disclosure_authorities',
                  'type' => 'select_box',
                  'display_name_all' => 'The authorities?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'disclosure_deny_details',
                  'type' => 'textarea',
                  'display_name_all' => 'If child does not agree, specify what cannot be shared and why.',
                  'matchable' => true
                  ),
        Field.new('name' => 'interview_place',
                  'type' => 'text_field',
                  'display_name_all' => 'Place of Interview',
                  'matchable' => true
                  ),
        Field.new('name' => 'interview_date',
                  'type' => 'date_field',
                  'display_name_all' => 'Date'
                  ),
        Field.new('name' => 'interview_subject',
                  'type' => 'select_box',
                  'display_name_all' => 'Information Obtained From',
                  'option_strings_text_all' => "the child\ncaregiver\nother",
                  'matchable' => true
                  ),
        Field.new('name' => 'interview_subject_details',
                  'type' => 'text_field',
                  'display_name_all' => 'If other, please specify',
                  'matchable' => true
                  ),
        Field.new('name' => 'interviewer',
                  'type' => 'text_field',
                  'display_name_all' => 'Name of Interviewer',
                  'matchable' => true
                  ),
        Field.new('name' => 'interviewers_org',
                  'type' => 'text_field',
                  'display_name_all' => "Interviewer's Organization",
                  'matchable' => true
                  ),
        Field.new('name' => 'governing_org',
                  'type' => 'text_field',
                  'display_name_all' => "Organization in charge of tracing child's family",
                  'matchable' => true
                  )
      ]
      FormSection.new('visible' => true, :order => 9,
                       :unique_id => 'interview_details', :fields => interview_details_fields,
                       'name_all' => 'Interview Details',
                       'description_all' => ''
      )
    end

    def self.build_other_tracing_info_section
      other_tracing_info_fields = [
        Field.new('name' => 'additional_tracing_info',
                  'type' => 'textarea',
                  'display_name_all' => 'Additional Info That Could Help In Tracing?',
                  'help_text_all' => 'Such as key persons/location in the life of the child who/which might provide information about the location of the sought family -- e.g. names of religious leader, market place, etc. Please ask the child where he/she thinks relatives and siblings might be, and if the child is in contact with any family friends. Include any useful information the caregiver provides.',
                  'matchable' => true
                  )
      ]

      FormSection.new('visible' => true, :order => 8,
                       :unique_id => 'other_tracing_info', :fields => other_tracing_info_fields,
                       'name_all' => 'Other Tracing Info',
                       'description_all' => ''
      )
    end

    def self.build_other_interviews_section
      other_interviews_fields = [
        Field.new('name' => 'other_org_interview_status',
                  'type' => 'select_box',
                  'display_name_all' => 'Has the child been interviewed by another organization?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'other_org_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Name of Organization',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_org_place',
                  'type' => 'text_field',
                  'display_name_all' => 'Place of Interview',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_org_country',
                  'type' => 'text_field',
                  'display_name_all' => 'Country',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_org_date',
                  'type' => 'date_field',
                  'display_name_all' => 'Date'
                  ),
        Field.new('name' => 'orther_org_reference_no',
                  'type' => 'text_field',
                  'display_name_all' => 'Reference No. given to child by other organization',
                  'matchable' => true
                  )
      ]
      FormSection.new('visible' => true, :order => 7,
                           :unique_id => 'other_interviews', :fields => other_interviews_fields,
                           'name_all' => 'Other Interviews',
                           'description_all' => ''
      )
    end

    def self.build_child_wishes_section
      child_wishes_fields = [
        Field.new('name' => 'wishes_name_1',
                  'type' => 'text_field',
                  'display_name_all' => 'Person child wishes to locate - Preferred',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_telephone_1',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_address_1',
                  'type' => 'textarea',
                  'display_name_all' => 'Last Known Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_name_2',
                  'type' => 'text_field',
                  'display_name_all' => 'Person child wishes to locate - Second Choice',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_telephone_2',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_address_2',
                  'type' => 'textarea',
                  'display_name_all' => 'Last Known Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_name_3',
                  'type' => 'text_field',
                  'display_name_all' => 'Person child wishes to locate - Third Choice',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_telephone_3',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_address_3',
                  'type' => 'textarea',
                  'display_name_all' => 'Last Known Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_contacted',
                  'type' => 'select_box',
                  'display_name_all' => 'Has the child heard from / been in contact with any relatives?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_contacted_details',
                  'type' => 'textarea',
                  'display_name_all' => 'Please give details',
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_wants_contact',
                  'type' => 'select_box',
                  'display_name_all' => 'Does child want to be reunited with family?',
                  'option_strings_text_all' => "Yes as soon as possible\nYes later\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'wishes_wants_contact_details',
                  'type' => 'textarea',
                  'display_name_all' => 'Please explain why',
                  'matchable' => true
                  )
      ]

      FormSection.new('visible' => true, :order => 6,
                       :unique_id => 'childs_wishes', :fields => child_wishes_fields,
                       'name_all' => "Child's Wishes",
                       'description_all' => ''
      )
    end

    def self.build_protection_concerns_section
      protection_concerns_fields = [
        Field.new('name' => 'concerns_chh',
                  'type' => 'select_box',
                  'display_name_all' => 'Child Headed Household',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_disabled',
                  'type' => 'select_box',
                  'display_name_all' => 'Disabled Child',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_medical_case',
                  'type' => 'select_box',
                  'display_name_all' => 'Medical Case',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_street_child',
                  'type' => 'select_box',
                  'display_name_all' => 'Street Child',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_girl_mother',
                  'type' => 'select_box',
                  'display_name_all' => 'Girl Mother',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_vulnerable_person',
                  'type' => 'select_box',
                  'display_name_all' => 'Living with Vulnerable Person',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_other',
                  'type' => 'text_field',
                  'display_name_all' => 'Other (please specify)',
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_further_info',
                  'type' => 'textarea',
                  'display_name_all' => 'Further Information',
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_needs_followup',
                  'type' => 'select_box',
                  'display_name_all' => 'Specific Follow-up Required?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'concerns_followup_details',
                  'type' => 'textarea',
                  'display_name_all' => 'Please specify follow-up needs.',
                  'matchable' => true
                  )
      ]

      FormSection.new('visible' => true, :order => 5,
                       :unique_id => 'protection_concerns', :fields => protection_concerns_fields,
                       'name_all' => 'Protection Concerns',
                       'description_all' => ''
      )
    end

    def self.build_separation_history_section
      separation_history_fields = [
        Field.new('name' => 'separation_place',
                  'display_name_all' => 'Place of Separation.',
                  'matchable' => true,
                  'type' => 'text_field'),
        Field.new('name' => 'separation_details',
                  'display_name_all' => 'Circumstances of Separation (please provide details)',
                  'matchable' => true,
                  'type' => 'textarea'),
        Field.new('name' => 'evacuation_status',
                  'display_name_all' => 'Has child been evacuated?',
                  'type' => 'select_box',
                  'matchable' => true,
                  'option_strings_text_all' => "Yes\nNo"),
        Field.new('name' => 'evacuation_agent',
                  'display_name_all' => 'If yes, through which organization?',
                  'matchable' => true,
                  'type' => 'text_field'),
        Field.new('name' => 'evacuation_from',
                  'display_name_all' => 'Evacuated From',
                  'matchable' => true,
                  'type' => 'text_field'),
        Field.new('name' => 'evacuation_to',
                  'display_name_all' => 'Evacuated To',
                  'matchable' => true,
                  'type' => 'text_field'),
        Field.new('name' => 'evacuation_date',
                  'display_name_all' => 'Evacuation Date',
                  'type' => 'date_field'),
        Field.new('name' => 'separation_care_arrangements_arrival_date',
                  'display_name_all' => 'Arrival Date',
                  'type' => 'date_field')
      ]
      FormSection.new('visible' => true,
                           :order => 4, :unique_id => 'separation_history', :fields => separation_history_fields,
                           'name_all' => 'Separation History',
                           'description_all' => "The child's separation and evacuation history."
                          )
    end

    def self.build_current_arrangements_section
      current_arrangements_fields = [
        Field.new('name' => 'care_arrangements',
                  'type' => 'select_box',
                  'display_name_all' => 'Current Care Arrangements',
                  'option_strings_text_all' => "Children's Center\nOther Family Member(s)\nFoster Family\nAlone\nOther",
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_other',
                  'type' => 'text_field',
                  'display_name_all' => 'If other, please provide details.',
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangments_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Full Name',
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_relationship',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship To Child',
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_knowsfamily',
                  'type' => 'select_box',
                  'display_name_all' => 'Does the caregiver know the family of the child?',
                  'option_strings_text_all' => "Yes\nNo",
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_familyinfo',
                  'type' => 'textarea',
                  'display_name_all' => "Caregiver's information about child or family",
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_address',
                  'type' => 'text_field',
                  'display_name_all' => "Child's current address (of caretaker or centre)",
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_came_from',
                  'type' => 'text_field',
                  'display_name_all' => 'Child Arriving From',
                  'matchable' => true
                  ),
        Field.new('name' => 'care_arrangements_arrival_date',
                  'type' => 'date_field',
                  'display_name_all' => 'Arrival Date'
                  ),
        Field.new('name' => 'care_arrangements_convoy_no',
                  'type' => 'text_field',
                  'display_name_all' => 'Convoy No',
                  'matchable' => true
                  )
      ]
      FormSection.new('visible' => true,
                       :order => 3, :unique_id => 'care_arrangements', :fields => current_arrangements_fields,
                       'name_all' => 'Care Arrangements',
                       'description_all' => "Information about the child's current caregiver"
      )
    end

    def self.build_family_details_section
      family_details_fields = [
        Field.new('name' => 'fathers_name',
                  'type' => 'text_field',
                  'display_name_all' => "Father's Name",
                  'matchable' => true
                  ),
        Field.new('name' => 'is_father_alive',
                  'type' => 'select_box',
                  'display_name_all' => 'Is Father Alive?',
                  'option_strings_text_all' => "Unknown\nAlive\nDead",
                  'matchable' => true
                  ),
        Field.new('name' => 'father_death_details',
                  'type' => 'text_field',
                  'display_name_all' => 'If dead, please provide details',
                  'matchable' => true
                  ),
        Field.new('name' => 'mothers_name',
                  'type' => 'text_field',
                  'display_name_all' => "Mother's Name",
                  'matchable' => true
                  ),
        Field.new('name' => 'is_mother_alive',
                  'type' => 'select_box',
                  'display_name_all' => 'Is Mother Alive?',
                  'option_strings_text_all' => "Unknown\nAlive\nDead",
                  'matchable' => true
                  ),
        Field.new('name' => 'mother_death_details',
                  'type' => 'text_field',
                  'display_name_all' => 'If dead, please provide details',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_family',
                  'type' => 'textarea',
                  'display_name_all' => 'Other persons well known to the child',
                  'matchable' => true
                  ),
        Field.new('name' => 'address',
                  'type' => 'textarea',
                  'display_name_all' => 'Address of child before separation (and person with whom he/she lived)',
                  'help_text_all' => 'If the child does not remember his/her address, please note other relevant information, such as descriptions of mosques, churches, schools and other landmarks.',
                  'matchable' => true
                  ),
        Field.new('name' => 'telephone',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone Before Separation',
                  'matchable' => true
                  ),
        Field.new('name' => 'caregivers_name',
                  'type' => 'text_field',
                  'display_name_all' => "Caregiver's Name (if different)",
                  'matchable' => true
                  ),
        Field.new('name' => 'is_caregiver_alive',
                  'type' => 'select_box',
                  'display_name_all' => 'Is Caregiver Alive?',
                  'option_strings_text_all' => "Unknown\nAlive\nDead",
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_1',
                  'type' => 'text_field',
                  'display_name_all' => '1) Sibling or other child accompanying the child',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_1_relationship',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_1_dob',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of Birth'
                  ),
        Field.new('name' => 'other_child_1_birthplace',
                  'type' => 'text_field',
                  'display_name_all' => 'Birthplace',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_1_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Current Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_1_telephone',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_2',
                  'type' => 'text_field',
                  'display_name_all' => '2) Sibling or other child accompanying the child',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_2_relationship',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_2_dob',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of Birth'
                  ),
        Field.new('name' => 'other_child_2_birthplace',
                  'type' => 'text_field',
                  'display_name_all' => 'Birthplace',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_2_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Current Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_2_telephone',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_3',
                  'type' => 'text_field',
                  'display_name_all' => '3) Sibling or other child accompanying the child',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_3_relationship',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_3_dob',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of Birth'
                  ),
        Field.new('name' => 'other_child_3_birthplace',
                  'type' => 'text_field',
                  'display_name_all' => 'Birthplace',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_3_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Current Address',
                  'matchable' => true
                  ),
        Field.new('name' => 'other_child_3_telephone',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone',
                  'matchable' => true
                  )
      ]

      FormSection.new('visible' => true,
                       :order => 2, :unique_id => 'family_details', :fields => family_details_fields,
                       'name_all' => 'Family Details',
                       'description_all' => "Information about a child's known family"
      )
    end

    def self.build_photo_audio_section
      photo_audio_fields = [
        Field.new('name' => 'current_photo_key',
                   'type' => 'photo_upload_box', 'editable' => false,
                   'display_name_all' => 'Current Photo Key'
                  ),
        Field.new('name' => 'recorded_audio',
                   'type' => 'audio_upload_box', 'editable' => false,
                   'display_name_all' => 'Recorded Audio'
                  )
      ]

      FormSection.new('visible' => true,
                       :order => 10, :unique_id => 'photos_and_audio', :fields => photo_audio_fields,
                       :perm_visible => true, 'editable' => false,
                       'name_all' => 'Photos and Audio',
                       'description_all' => 'All Photo and Audio Files Associated with a Child Record'
      )
    end

    def self.build_basic_identity_section
      basic_identity_fields = [
        Field.new('name' => 'name',
                  'type' => 'text_field',
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 1),
                  'display_name_all' => 'Name',
                  'matchable' => true
                  ),
        Field.new('name' => 'protection_status',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Unaccompanied\nSeparated",
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 3),
                  'display_name_all' => 'Protection Status',
                  'help_text_all' => 'A separated child is any person under the age of 18, separated from both parents or from his/her previous legal or customary primary care giver, but not necessarily from other relatives. An unaccompanied child is any person who meets those criteria but is ALSO separated from his/her relatives.',
                  'matchable' => true
                  ),
        Field.new('name' => 'ftr_status',
                  'type' => 'select_box',
                  'option_strings_text' => "Identified\nVerified\nTracing On-Going\nFamily Located Cross-Border FR Pending\nFamily Located Inter-Camp FR Pending\nReunited\nExported to CPIMS\nRecord Invalid",
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 4),
                  'display_name_all' => 'FTR Status',
                  'matchable' => true
                  ),
        Field.new('name' => 'why_record_invalid',
                  'type' => 'text_field',
                  'display_name_all' => "If 'Record Invalid', explain why?",
                  'matchable' => true
                  ),
        Field.new('name' => 'id_document',
                  'type' => 'text_field',
                  'display_name_all' => 'UNHCR No.',
                  'matchable' => true
                  ),
        Field.new('name' => 'rc_id_no',
                  'type' => 'text_field',
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 2),
                  'display_name_all' => 'RC ID No.',
                  'matchable' => true
                  ),
        Field.new('name' => 'icrc_ref_no',
                  'type' => 'text_field',
                  'display_name_all' => 'ICRC Ref No.',
                  'matchable' => true
                  ),
        Field.new('name' => 'gender',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Male\nFemale",
                  'display_name_all' => 'Sex',
                  'matchable' => true
                  ),
        Field.new('name' => 'nick_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Also Known As (nickname)',
                  'matchable' => true
                  ),
        Field.new('name' => 'names_origin',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Yes\nNo",
                  'display_name_all' => 'Name(s) given to child after separation?',
                  'matchable' => true
                  ),
        Field.new('name' => 'date_of_birth',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of Birth (dd/mm/yyyy)'
                  ),
        Field.new('name' => 'birthplace',
                  'type' => 'text_field',
                  'display_name_all' => 'Birthplace',
                  'matchable' => true
                  ),
        Field.new('name' => 'nationality',
                  'type' => 'text_field',
                  'display_name_all' => 'Nationality',
                  'matchable' => true
                  ),
        Field.new('name' => 'ethnicity_or_tribe',
                  'type' => 'text_field',
                  'display_name_all' => 'Ethnic group / tribe',
                  'matchable' => true
                  ),
        Field.new('name' => 'languages',
                  'type' => 'text_field',
                  'display_name_all' => 'Languages spoken',
                  'matchable' => true
                  ),
        Field.new('name' => 'characteristics',
                  'type' => 'textarea',
                  'display_name_all' => 'Distinguishing Physical Characteristics',
                  'matchable' => true
                  ),
        Field.new('name' => 'documents',
                  'type' => 'text_field',
                  'display_name_all' => 'Documents carried by the child',
                  'matchable' => true
                  )
      ]
      FormSection.new('visible' => true,
                       :order => 1, :unique_id => 'basic_identity', 'editable' => true,
                       :fields => basic_identity_fields,
                       'name_all' => 'Basic Identity',
                       'description_all' => 'Basic identity information about a separated or unaccompanied child.'
      )
    end
  end
end
