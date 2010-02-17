class Schema

  def self.get_schema
    [
            {       "name" => "basic_details",
                    "type" => "form",
                    "fields" => [
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
                                    "type" => "radio_button",
                                    "options" =>["exact", "approximate"]
                            },
                            {
                                    "name" => "gender",
                                    "type" => "radio_button",
                                    "options" => ["male", "female"]
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
                            }]
            },
            {

                    "name" => "family_details",
                    "type" => "form",
                    "fields" => [
                            {
                                    "name" => "uncle_name",
                                    "type" => "text_field"
                            },
                            {
                                    "name" => "auntie_name",
                                    "type" => "text_field"

                            }]
            }
    ]
  end

  def self.keys_in_order
    keys = []
    get_schema["fields"].each do |field|
      keys << field["name"]
    end
    return keys
  end

  def self.fields_in_order_for_form(form_name)
    get_schema.each do |form|
      if form["name"] == form_name
        return form["fields"].collect {|field| field["name"]}
      end
      return []
    end
  end

  def self.order_fields_according_to_form(fields, form_name)
    ordered_fields = fields_in_order_for_form(form_name).reject { |field_name| not fields.include? field_name}

    remaining_fields = fields - ordered_fields
    return ordered_fields + remaining_fields.sort
  end


end
