module CustomFieldValidations
  def validate_custom_field_types
    fields = FormSection.all_by_order.select{|fs|fs.enabled}.collect{ |fs| fs[:fields] }.flatten
    fields.each do |field|
      case field[:type]
      when Field::NUMERIC_FIELD
        validate_numeric_field field
      when Field::TEXT_FIELD
        validate_text_field field
      when Field::TEXT_AREA
        validate_text_area field
      end
    end
    return [self.errors.blank?, '']
  end
  
  def value_for_field field
    return (self[field.name]||"").strip
  end
  
  def validate_numeric_field field
    value = value_for_field(field)
    if value.present? and (value =~ /^\d*\.{0,1}\d+$/).nil?
      self.errors.add(field[:name], "#{field[:display_name]} must be a valid number")
    end
  end
  def validate_text_field field
    value = value_for_field(field)
    if value.length>200  
      self.errors.add(field.name, "#{field.display_name} cannot be more than 200 characters long") 
    end
  end
  def validate_text_area field
    value = value_for_field(field)
    if value.length>400  
      self.errors.add(field.name, "#{field.display_name} cannot be more than 400 characters long") 
    end
  end
end