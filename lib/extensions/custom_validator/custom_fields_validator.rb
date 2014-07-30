class CustomFieldsValidator
  def initialize(target, options)
    form = target.form
    fields = retrieve_field_definitions(target, form)
    validated_fields = fields.select { |field| field.type == options[:type] }
    validate_fields(validated_fields, target)
  end

  def retrieve_field_definitions(target, form)
    if !form.nil? && form.respond_to?(:name) && !form.name.nil?
      return target.field_definitions_for(form.name) if (target.respond_to? :field_definitions_for) && !target.field_definitions_for(form.name).nil?
      return FormSection.all_visible_child_fields_for_form form.name
    end
    return []
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

module Extensions
  module CustomValidator
    module CustomFieldsValidator
      class FieldValidator  < ActiveModel::Validator
        def validate(record)
          case @options[:type]
            when Field::NUMERIC_FIELD
              validator = CustomNumericFieldsValidator
            when Field::TEXT_FIELD
              validator = CustomTextFieldsValidator
            when Field::TEXT_AREA
              validator = CustomTextAreasValidator
            when Field::DATE_FIELD
              validator = DateFieldsValidator
            else
              raise "Unrecognised field type " + field_type.to_s + " for validation"
          end
          validator.new(record, @options) if validator
        end
      end
    end
  end
end

