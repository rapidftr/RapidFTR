require 'couchrest/mixins/validation'

module CouchRest
  module Validation
    class CustomFieldsValidator < GenericValidator
      
      def initialize(field_type, options)
        super
        @options = options
        @type = field_type.to_s
      end
      def retrieve_field_definitions target
				return target.field_definitions if (target.respond_to? :field_definitions) && !target.field_definitions.nil?
				return FormSection.all_enabled_child_fields
			end
      def call(target)
        fields = retrieve_field_definitions target
        validated_fields = fields.select { |field| field[:type] == @type }
        return validate_fields(validated_fields, target)
      end
      
      def validate_fields(fields, target)
        valid = true
        fields.each do |field|
          field_name = field[:name]
          value = target[field_name].nil? ? '' : target[field_name].strip
          
          if value.present? and is_not_valid(value)
            add_error(target, validation_message_for(field), field_name) 
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
        "#{field[:display_name]} must be a valid number"
      end
    end
    
    class CustomTextFieldsValidator < CustomFieldsValidator
      def is_not_valid value
        value.length > 200
      end
      def validation_message_for field
        "#{field[:display_name]} cannot be more than 200 characters long"
      end
    end
    class CustomTextAreasValidator < CustomFieldsValidator
      MAX_LENGTH = 400_000
      def is_not_valid value
        value.length > MAX_LENGTH
      end
      def validation_message_for field
        "#{field[:display_name]} cannot be more than #{MAX_LENGTH} characters long"
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
        "#{field[:display_name]} must follow this format: 4 Feb 2010"
      end
    end

    
    module ValidatesCustomFields

      def validates_fields_of_type field_type
        opts = opts_from_validator_args([])
        add_validator_to_context(opts, field_type, validation_for_type(field_type))
      end
      
      def validation_for_type field_type
        case field_type
          when Field::NUMERIC_FIELD
            CouchRest::Validation::CustomNumericFieldsValidator
          when Field::TEXT_FIELD
            CouchRest::Validation::CustomTextFieldsValidator
          when Field::TEXT_AREA
            CouchRest::Validation::CustomTextAreasValidator
          when Field::DATE_FIELD
            CouchRest::Validation::DateFieldsValidator
        else
          raise "Unrecognised field type " + field_type.to_s + " for validation"
        end
      end
    end 
    
    module ClassMethods
      include CouchRest::Validation::ValidatesCustomFields
    end
    
  end
end
