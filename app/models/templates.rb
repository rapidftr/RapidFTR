class Templates

  TEMPLATES = {
          "basic_details" => [
                  {
                          "name" => "name",
                          "type" => "text_field"
                  },
                  {
                          "name" => "age",
                          "type" => "text_field"
                  },
                  {
                          "name" => "age_is",
                          "type" => "select_box",
                          "options" => ["Approximate", "Exact"]
                  },
                  {
                          "name" => "gender",
                          "type" => "radio_button",
                          "options" => ["Male", "Female"]
                  },
                  {
                          "name" => "origin",
                          "type" => "text_field"
                  },
                  {
                          "name" => "last_known_location",
                          "type" => "text_field"
                  },
                  {
                          "name" => "date_of_separation",
                          "type" => "select_box",
                          "options" => ["", "1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]
                  },
                  {
                          "name" => "current_photo_key",
                          "type" => "photo_upload_box"
                  }
          ],

          "family_details" => [
                  {
                          "name" => "fathers_name",
                          "type" => "text_field"
                  },
                  {
                          "name" => "reunite_with_father",
                          "type" => "select_box",
                          "options" =>["Yes", " No"]
                  },
                  {
                          "name" => "mothers_name",
                          "type" => "text_field"
                  },
                  {
                          "name" => "reunite_with_mother",
                          "type" => "select_box",
                          "options" =>["Yes", " No"]
                  },

          ],

          "caregiver_details" => [
                  {
                          "name" => "caregivers_name",
                          "type" => "text_field"
                  },
                  {
                          "name" => "occupation",
                          "type" => "text_field"
                  },
                  {
                          "name" => "relationship_to_child",
                          "type" => "text_field"
                  },
          ]

  }

  def self.get_template(template_name)
    TEMPLATES[template_name]
  end

  def self.child_form_section_names
    ["basic_details", "family_details", "caregiver_details"]
  end

  def self.all_child_field_names
    all_child_fields.map{ |field| field["name"] }
  end

  def self.all_child_fields
    child_form_section_names.map do |section|
      get_template(section)
    end.flatten
  end

  def self.get_search_result_template
    [
            {
                    "name" => "name",
                    "type" => "text_field"
            },
            {
                    "name" => "age",
                    "type" => "text_field"
            },
            {
                    "name" => "is_age_exact",
                    "type" => "select_box",
                    "options" => ["Exact", "Approximate"]
            },
            {
                    "name" => "gender",
                    "type" => "radio_button",
                    "options" => ["Male", "Female"]
            },
            {
                    "name" => "origin",
                    "type" => "text_field"
            },
            {
                    "name" => "last_known_location",
                    "type" => "text_field"
            },
            {
                    "name" => "date_of_separation",
                    "type" => "select_box",
                    "options" => ["1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]
            }
    ]
  end

end
