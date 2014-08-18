module RapidFTR
  module FollowUpFormSectionSetup
    def self.reset_definitions
      form = Form.find_by_name(Child::FORM_NAME)
      outcome_of_follow_up_visit_fields = [
        Field.new('name' => 'was_child_seen',
                  'type' => 'select_box',
                  'option_strings_text' => "Yes\nNo",
                  'display_name_all' => 'Was the child seen during the visit?'
                  ),
        Field.new('name' => 'reason_why',
                  'type' => 'check_boxes',
                  'option_strings_text_all' => "Abducted\nAt School\nChild in Detention\nMoved onto street/Market\nMoved to live with another caregiver\nVisiting Friends/Relatives\nWorking /At work ",
                  'display_name_all' => 'If not, why?'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 11, :unique_id => 'outcome_of_follow_up_visit', 'editable' => true,
                           :fields => outcome_of_follow_up_visit_fields,
                           'name_all' => 'Outcome of Follow Up Visit',
                           'description_all' => 'Information to be added',
                           :form => form
                          )

      current_care_arrangements_fields = [
        Field.new('name' => 'child_living_with_same_caregiver',
                  'type' => 'select_box',
                  'option_strings_text' => "Yes\nNo",
                  'display_name_all' => 'Is the child still living with the same caregiver?'
                  ),
        Field.new('name' => 'reasons_for_change',
                  'type' => 'select_box',
                  'option_strings_text' => "Abuse Exploitation\nDeath of caregiver\nEducation\nIll health of caregiver\nOther\nPoverty\nRelationship Breakdown",
                  'display_name_all' => 'If not, give reasons for change'
                  ),
        Field.new('name' => 'type_of_current_arrangements',
                  'type' => 'select_box',
                  'option_strings_text' => "Child Headed Household \nFoster Family\nInterim care center\nInterim care center\nOrphanage\nTemporary Care Center\nStreet\nOther",
                  'display_name_all' => 'If not, give the type of current care arrangements?'
                  ),
        Field.new('name' => 'first_name_of_caregiver',
                  'type' => 'text_field',
                  'display_name_all' => 'If not, give the first name of the caregiver'
                  ),
        Field.new('name' => 'middle_name_of_caregiver',
                  'type' => 'text_field',
                  'display_name_all' => 'Middle name of the caregiver'
                  ),
        Field.new('name' => 'last_name_of_caregiver',
                  'type' => 'text_field',
                  'display_name_all' => 'Last name of the caregiver'
                  ),
        Field.new('name' => 'location_of_new_caregiver',
                  'type' => 'text_field',
                  'display_name_all' => 'Location of new caregiver'
                  ),
        Field.new('name' => 'address_of_caregiver',
                  'type' => 'textarea',
                  'display_name_all' => 'Address of caregiver'
                  ),
        Field.new('name' => 'telephone_contact_of_caregiver',
                  'type' => 'text_field',
                  'display_name_all' => 'Telephone contact of caregiver'
                  ),
        Field.new('name' => 'relationship_of_caregiver_to_child',
                  'type' => 'text_field',
                  'display_name_all' => 'Relationship of new caregiver to child'
                  ),

        Field.new('name' => 'date_new_arrangement_started',
                  'type' => 'text_field',
                  'display_name_all' => 'Date new care arrangement started'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 12, :unique_id => 'current_care_arrangement', 'editable' => true,
                           :fields => current_care_arrangements_fields,
                           'name_all' => 'Current Care Arrangements',
                           'description_all' => 'Information to be added',
                           :form => form
                          )

      activities_fields = [
        Field.new('name' => 'is_child_in_school_or_training',
                  'type' => 'select_box',
                  'option_strings_text' => "Yes\nNo",
                  'display_name_all' => 'Is the Child in School or training?'
                  ),
        Field.new('name' => 'name_of_school',
                  'type' => 'text_field',
                  'display_name_all' => 'Name of School'
                  ),
        Field.new('name' => 'why_not_in_school',
                  'type' => 'check_boxes',
                  'option_strings_text_all' => "Child Labour\nEarly Marriage\nFinancial Constraints\nIgnorance\nLack of Infrastructure\nLack of Access\nLack of Infrastructure\nLack of interest\npregnancy /children\npregnancy /child\nSent abroad for job\nOther",
                  'display_name_all' => 'If not, why not?'
                  ),
        Field.new('name' => 'what_type_of_education',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Accelerated learning\nEarly Childhood\nNon-Formal Education\nPrimary\nSecondary\nVocational\nVocational training",
                  'display_name_all' => 'If yes, what type of education?'
                  ),
        Field.new('name' => 'what_have_they_achieved',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Capentry\nGS1\nGS2\nGS3\Hairdressing\nlevel 1\nlevel 2\nlevel 3\nlevel 4\nSS1\nSS2\nSS3\nTailoring\nWoodwork",
                  'display_name_all' => 'If relevant, what level have they achieved?'
                  ),
        Field.new('name' => 'other_activities_child_involved_in',
                  'type' => 'check_boxes',
                  'option_strings_text_all' => "Community activities\nLivelihood activities\nRecreational Activities",
                  'display_name_all' => 'What other activities is the child involved in?'
                  ),
        Field.new('name' => 'start_date_of_training',
                  'type' => 'text_field',
                  'display_name_all' => 'Start Date of Training'
                  ),
        Field.new('name' => 'duration_of_training',
                  'type' => 'text_field',
                  'display_name_all' => 'Duration of Training'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 13, :unique_id => 'activities', 'editable' => true,
                           :fields => activities_fields,
                           'name_all' => 'Activities',
                           'description_all' => 'Information to be added',
                           :form => form
                          )

      care_assessment_fields = [
        Field.new('name' => 'personal_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Personal assessment?'
                  ),
        Field.new('name' => 'family_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Family assessment?'
                  ),
        Field.new('name' => 'community_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Community assessment?'
                  ),
        Field.new('name' => 'education_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Education assessment?'
                  ),
        Field.new('name' => 'health_and_nutrition_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Health and Nutrition assessment?'
                  ),
        Field.new('name' => 'economical_assessment',
                  'type' => 'select_box',
                  'option_strings_text_all' => "No Further Action Needed\nOngoing Monitoring\nUrgent Intervention",
                  'display_name_all' => 'Economical assessment?'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 14, :unique_id => 'care_assessment', 'editable' => true,
                           :fields => care_assessment_fields,
                           'name_all' => 'Care Assessment',
                           'description_all' => 'Information to be added',
                           :form => form
                          )

      further_action_fields = [
        Field.new('name' => 'any_need_for_follow_up_visit',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Yes\nNo",
                  'display_name_all' => 'Is there a need for further follow up visit(s)?'
                  ),
        Field.new('name' => 'when_follow_up_visit_should_happen',
                  'type' => 'text_field',
                  'display_name_all' => 'If yes, when do you recommend the next visit to take place?'
                  ),
        Field.new('name' => 'recommend_that_the_case_be_closed',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Yes\nNo",
                  'display_name_all' => 'If not, do you recommend that the case be closed?'
                  ),
        Field.new('name' => 'any_comments',
                  'type' => 'textarea',
                  'display_name_all' => 'Comments'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 15, :unique_id => 'further_action', 'editable' => true,
                           :fields => further_action_fields,
                           'name_all' => 'Further Action',
                           'description_all' => 'Information to be added',
                           :form => form
                          )

      additional_family_details_fields = [
        Field.new('name' => 'size_of_family',
                  'type' => 'text_field',
                  'display_name_all' => 'Size of Family'
                  ),
        Field.new('name' => 'type_of_follow_up',
                  'type' => 'select_box',
                  'option_strings_text_all' => "Follow-Up After ReUnification\nFollow-Up in Care",
                  'display_name_all' => 'Type of follow up'
                  )
      ]

      FormSection.create!('visible' => false,
                           :order => 15, :unique_id => 'additional_family_details', 'editable' => true,
                           :fields => additional_family_details_fields,
                           'name_all' => 'Additional Family Details',
                           'description_all' => 'Information to be added',
                           :form => form
                          )
      true
    end
  end
end
