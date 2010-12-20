require 'couchrest/mixins/validation'

module CouchRest
  module Validation
    class CustomNumericFieldsValidator < GenericValidator
      
      def initialize(field_name, options)
        super
        @field_name, @options = field_name, options
        @type = options[:type]
      end
      
      def call(target)
        validated_fields = []
        fields = FormSection.all_by_order.collect{ |fs| fs[:fields] }.flatten
        fields.each { |field| validated_fields << field if field[:type] == @type }
        
        return validate_fields(validated_fields, target)
      end
      
      def validate_fields(fields, target)
        valid = true
        fields.each do |field|
          field_name = field[:name]
          value = target[field_name].nil? ? '' : target[field_name].strip
          
          if value.present? and (value =~ /^\d*\.{0,1}\d+$/).nil?
            add_error(target, "#{field[:display_name]} must be a valid number", field_name) 
            valid = false
          end
        end
        return valid
      end
        
    end
    
    module ValidatesCustomFields

      def validates_fields_of_type(*fields)
        opts = opts_from_validator_args(fields)
        opts.merge!({:type => 'numeric_field'})
        add_validator_to_context(opts, fields, CouchRest::Validation::CustomNumericFieldsValidator)
      end
      
    end 
    
    module ClassMethods
      include CouchRest::Validation::ValidatesCustomFields
    end
    
  end
end