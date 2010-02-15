class Schema

  def self.get_schema
    {
            :fields => [
                    {
                            :name => "name",
                            :type => "text_field"
                    },
                    {
                            :name => "age",
                            :type => "text_field"
                    },
                    {
                            :name => "is_age_exact",
                            :type => "radio_button",
                            :options =>["exact", "approximate"]
                    },
                    {
                            :name => "gender",
                            :type => "radio_button",
                            :options => ["male", "female"]
                    },
                    {
                            :name => "origin",
                            :type => "text_field"
                    },
                    {
                            :name => "last_known_location",
                            :type => "text_field"
                    },
                    {
                            :name => "date_of_separation",
                            :type => "select_box",
                            :options => ["1-2 weeks ago", "2-4 weeks ago", "1-6 months ago", "6 months to 1 year ago", "More than 1 year ago"]
                    }
            ]
    }
#    [
#
#            Field.new("name", "text_field"),
#            RadioButtonField.new("gender", ["male", "female"]),
#            Field.new("age", "text_field"),
#            RadioButtonField.new("is_age_exact", ["exact", "approximate"]),
#            Field.new("origin", "text_field"),
#            Field.new("last_known_location", "text_field"),
#            Field.new("uncle_name", "repeatable_text_field"),
#            Field.new("auntie_name", "repeatable_text_field"),
#            Field.new("sibling_name", "repeatable_text_field"),
#            Field.new("cousin_name", "repeatable_text_field"),
#    ]
  end
end