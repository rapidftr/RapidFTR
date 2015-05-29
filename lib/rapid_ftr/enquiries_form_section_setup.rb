module RapidFTR
  module EnquiriesFormSectionSetup
    def self.build_form_sections
      form_sections = []
      form_sections << build_details_of_adult_seeking_child_section
      unless Rails.env.test? || Rails.env.cucumber?
        form_sections << build_details_of_child_sought_fields_section
        form_sections << build_family_details_section
        form_sections << build_separation_history_section
        form_sections << build_location_of_child_section
        form_sections << build_details_of_interview_section
        form_sections << build_photo_audio_section
      end
      form_sections
    end

    def self.reset_form
      FormSection.all.each { |f| f.destroy  if f.form.name == Enquiry::FORM_NAME  }
      Form.all.each { |f| f.destroy if f.name == Enquiry::FORM_NAME }
      Form.create(:_id => '7caed4ef-4001-44d7-977b-529e934ea1db', :name => Enquiry::FORM_NAME)
    end

    def self.reset_definitions
      form = reset_form
      build_form_sections.each do |fs|
        fs.form = form
        fs.save!
      end
      true
    end

    def self.build_details_of_adult_seeking_child_section
      details_of_adult_seeking_child_fields = [
        Field.new('name' => 'enq_first_name',
                  'type' => 'text_field',
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 1),
                  'display_name_all' => 'First Name',
                  'matchable' => true
        ),
        Field.new('name' => 'enq_middle_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Middle Name',
                  'matchable' => true
        ),
        Field.new('name' => 'enq_last_name',
                  'type' => 'text_field',
                  'highlight_information' => HighlightInformation.new('highlighted' => true, 'order' => 2),
                  'display_name_all' => 'Last Name',
                  'matchable' => true
        ),
        Field.new('name' => 'enq_gender',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Male\nFemale",
                  'display_name_all' => 'Sex'
        ),
        Field.new('name' => 'enq_date_of_birth',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of Birth (dd/mm/yyyy)'
        ),
        Field.new('name' => 'enq_birthplace',
                  'type' => 'text_field',
                  'display_name_all' => 'Birthplace'
        ),
        Field.new('name' => 'enq_country',
                  'type' => 'text_field',
                  'display_name_all' => 'Country'
        ),
        Field.new('name' => 'enq_address_admin_level',
                  'type' => 'text_field',
                  'display_name_all' => 'Admin Level'
        ),
        Field.new('name' => 'enq_address_physical_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Village/Area/Physical Address',
                  'help_text_all' => 'if not known enter landmarks e.g. hills, trees, names of schools or hospital etc.'
        ),
        Field.new('name' => 'enq_telephone_number',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone Number',
                  'matchable' => true
        ),
        Field.new('name' => 'enq_ethnic_affiliation',
                  'type' => 'text_field',
                  'display_name_all' => 'Ethnic Affiliation'
        ),
        Field.new('name' => 'enq_nationality',
                  'type' => 'text_field',
                  'display_name_all' => 'Nationality'
        ),
        Field.new('name' => 'enq_relationship',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship to missing child',
                  'help_text_all' => 'mother, father, grandmother, grandfather, aunt, uncle, sibling, etc.?'
        ),
        Field.new('name' => 'enq_message_for_child',
                  'type' => 'textarea',
                  'display_name_all' => 'Does the Inquirer have a message for the child?'
        )
      ]

      FormSection.new('visible' => true,
                      :order => 1, :unique_id => 'enq_details_of_adult_seeking_child', 'editable' => true,
                      :fields => details_of_adult_seeking_child_fields,
                      'name_all' => 'Details of the Adult Seeking a Child',
                      'description_all' => 'Details of the adult seeking a child'
      )
    end

    def self.build_details_of_child_sought_fields_section
      details_of_child_sought_fields = [
        Field.new('name' => '2_first_name',
                  'type' => 'text_field',
                  'display_name_all' => 'First Name',
                  'matchable' => true
        ),
        Field.new('name' => '2_middle_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Middle Name',
                  'matchable' => true
        ),
        Field.new('name' => '2_last_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Last Name',
                  'matchable' => true
        ),
        Field.new('name' => '2_other_names',
                  'type' => 'text_field',
                  'display_name_all' => 'Other names or spellings child known by',
                  'matchable' => true
        ),
        Field.new('name' => '2_gender',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Male\nFemale",
                  'display_name_all' => 'Sex',
                  'matchable' => true
        ),
        Field.new('name' => '2_year_of_birth',
                  'type' => 'text_field',
                  'display_name_all' => 'Year of Birth'
        ),
        Field.new('name' => '2_language',
                  'type' => 'text_field',
                  'display_name_all' => 'Languages spoken by the child'
        ),
        Field.new('name' => '2_religion',
                  'type' => 'text_field',
                  'display_name_all' => 'Childs Religion'
        ),
        Field.new('name' => '2_nationality',
                  'type' => 'text_field',
                  'display_name_all' => 'Nationality'
        ),
        Field.new('name' => '2_child_ethnic_affiliation',
                  'type' => 'text_field',
                  'display_name_all' => "Child's Ethnic Affiliation"
        ),
        Field.new('name' => '2_physical_characteristics',
                  'type' => 'textarea',
                  'display_name_all' => 'Distinguishing physical characteristics',
                  'matchable' => true
        ),
        Field.new('name' => '2_last_school_attended',
                  'type' => 'text_field',
                  'display_name_all' => 'Last School Attended'
        ),
        Field.new('name' => '2_school_level',
                  'type' => 'text_field',
                  'display_name_all' => 'Level'
        )
      ]

      FormSection.new('visible' => true,
                      :order => 2, :unique_id => 'enq_details_of_child_sought', 'editable' => true,
                      :fields => details_of_child_sought_fields,
                      'name_all' => 'Details of Child Sought',
                      'description_all' => 'Details of the child being sought'
      )
    end

    def self.build_family_details_section
      family_details_fields = [
        Field.new('name' => '3_father_first_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Father - First Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_father_middle_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Father - Middle Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_father_last_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Father - Last Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_father_current_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Father\'s current address',
                  'matchable' => true
        ),
        Field.new('name' => '3_mother_first_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Mother - First Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_mother_middle_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Mother - Middle Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_mother_last_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Child\'s Mother - Last Name',
                  'matchable' => true
        ),
        Field.new('name' => '3_mother_current_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Mother\'s current address',
                  'matchable' => true
        ),
        Field.new('name' => '3_father_alive',
                  'type' => 'select_box',
                  'option_strings_text' => "Yes\nNo\nDont Know",
                  'display_name_all' => 'Is the father alive?'
        ),
        Field.new('name' => '3_mother_alive',
                  'type' => 'select_box',
                  'option_strings_text' => "Yes\nNo\nDont Know",
                  'display_name_all' => 'Is the mother alive?'
        ),
        Field.new('name' => '3_if_father_or_mother_dead_details',
                  'type' => 'textarea',
                  'display_name_all' => 'If father or mother believed dead, give details'
        )
      ]

      FormSection.new('visible' => true,
                      :order => 3, :unique_id => 'enq_family_details', 'editable' => true,
                      :fields => family_details_fields,
                      'name_all' => 'Family Details',
                      'description_all' => "Details of the child's family"
      )
    end

    def self.build_separation_history_section
      separation_history_fields = [
        Field.new('name' => '4_permanent_address',
                  'type' => 'text_field',
                  'display_name_all' => 'Permanent address prior to separation',
                  'matchable' => true
        ),
        Field.new('name' => '4_telephone_number',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone number',
                  'matchable' => true
        ),
        Field.new('name' => '4_date_of_separation',
                  'type' => 'text_field',
                  'display_name_all' => 'Date/Year of Separation'
        ),
        Field.new('name' => '4_cause_of_separation',
                  'type' => 'select_box',
                  'option_strings_text' => "Voluntary\nAbandoned\nDomestic Violence\nPoverty\nAbducted\nSickness of family member\nWar\nDeath\nRepatriation\nDivorce/Remarriage\nNatural Disaster\nOther",
                  'display_name_all' => 'What is the main cause of separation?'
        ),
        Field.new('name' => '4_separation_circumstances',
                  'type' => 'textarea',
                  'display_name_all' => 'Describe the circumstances of separation'
        ),
        Field.new('name' => '4_place_of_separation',
                  'type' => 'text_field',
                  'display_name_all' => 'Place of Separation',
                  'matchable' => true
        )
      ]

      FormSection.new('visible' => true,
                      :order => 4, :unique_id => 'enq_separation_history', 'editable' => true,
                      :fields => separation_history_fields,
                      'name_all' => 'History of Separation',
                      'description_all' => 'Separation history'
      )
    end

    def self.build_location_of_child_section
      location_of_child_fields = [
        Field.new('name' => '5_location',
                  'type' => 'text_field',
                  'display_name_all' => 'Possible Location of the child',
                  'matchable' => true
        ),
        Field.new('name' => '5_latest_news_received',
                  'type' => 'textarea',
                  'display_name_all' => 'Latest News Received'
        ),
        Field.new('name' => '5_name_of_family_member_with_child',
                  'type' => 'text_field',
                  'display_name_all' => 'Name of family member with the child',
                  'matchable' => true
        )
      ]

      FormSection.new('visible' => true,
                      :order => 5, :unique_id => 'enq_location_of_child', 'editable' => true,
                      :fields => location_of_child_fields,
                      'name_all' => 'Possible Location of the Child/Possible Tracing Location',
                      'description_all' => 'Possible tracing location'
      )
    end

    def self.build_details_of_interview_section
      details_of_interview_fields = [
        Field.new('name' => '6_name',
                  'type' => 'text_field',
                  'display_name_all' => 'Name'
        ),
        Field.new('name' => '6_position',
                  'type' => 'text_field',
                  'display_name_all' => 'Position'
        ),
        Field.new('name' => '6_agency',
                  'type' => 'text_field',
                  'display_name_all' => 'Agency'
        ),
        Field.new('name' => '6_date_of_interview',
                  'type' => 'date_field',
                  'display_name_all' => 'Date of interview (dd/mm/yyyy)'
        ),
        Field.new('name' => '6_location_of_interview',
                  'type' => 'text_field',
                  'display_name_all' => 'Location of interview'
        )
      ]

      FormSection.new('visible' => true,
                      :order => 6, :unique_id => 'enq_details_of_interview', 'editable' => true,
                      :fields => details_of_interview_fields,
                      'name_all' => 'Details of Interview',
                      'description_all' => 'Details of interview'
      )
    end

    def self.build_photo_audio_section
      photo_audio_fields = [
        Field.new('name' => '7_current_photo_key',
                   'type' => 'photo_upload_box', 'editable' => false,
                   'display_name_all' => 'Current Photo Key'
                  ),
        Field.new('name' => '7_recorded_audio',
                   'type' => 'audio_upload_box', 'editable' => false,
                   'display_name_all' => 'Recorded Audio'
                  )
      ]

      FormSection.new('visible' => true,
                       :order => 10, :unique_id => 'enq_photos_and_audio', :fields => photo_audio_fields,
                       :perm_visible => true, 'editable' => false,
                       'name_all' => 'Photos and Audio',
                       'description_all' => 'All Photo and Audio Files Associated with a Child Record'
      )
    end
  end
end
