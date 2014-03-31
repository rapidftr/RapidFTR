class CustomFieldsValidator

  def initialize(record, options)
    @options = options
    call(record) if record
  end

  def retrieve_field_definitions(target)
    return target.field_definitions if (target.respond_to? :field_definitions) && !target.field_definitions.nil?
    return FormSection.all_enabled_child_fields
  end

  def call(target)
    fields = retrieve_field_definitions(target)
    validated_fields = fields.select { |field| field.type == @options[:type] }
    return validate_fields(validated_fields, target)
  end

  def validate_fields(fields, target)
    valid = true
    fields.each do |field|
      field_name = field[:name]
      value = target[field_name].nil? ? '' : target[field_name].strip

      if value.present? and is_not_valid(value)
        target.errors.add(:"#{field[:name]}", validation_message_for(field))
        valid = false
      end
    end
    return valid
  end
end

class CustomNumericFieldsValidator < CustomFieldsValidator
  def is_not_valid value
    !value.is_number?
  end
  def validation_message_for field
    "#{field.display_name} must be a valid number"
  end
end

class CustomTextFieldsValidator < CustomFieldsValidator
  def is_not_valid value
    value.length > 200
  end
  def validation_message_for field
    "#{field.display_name} cannot be more than 200 characters long"
  end
end

class CustomTextAreasValidator < CustomFieldsValidator
  MAX_LENGTH = 400_000
  def is_not_valid value
    value.length > MAX_LENGTH
  end
  def validation_message_for field
    "#{field.display_name} cannot be more than #{MAX_LENGTH} characters long"
  end
end

class DateFieldsValidator < CustomFieldsValidator
  # Blackberry client can only parse specific date formats
  def is_not_valid value
    begin
      Date.strptime(value, '%d %b %Y')
      false
    rescue
      true
    end
  end
  def validation_message_for field
    "#{field.display_name} must follow this format: 4 Feb 2010"
  end
end

class FieldValidator  < ActiveModel::Validator
  def validate(record)
    case @options[:type]
      when Field::NUMERIC_FIELD
        CustomNumericFieldsValidator.new(record, @options)
      when Field::TEXT_FIELD
        CustomTextFieldsValidator.new(record, @options)
      when Field::TEXT_AREA
        CustomTextAreasValidator.new(record, @options)
      when Field::DATE_FIELD
        DateFieldsValidator.new(record, @options)
      else
        raise "Unrecognised field type " + field_type.to_s + " for validation"
    end
  end
end