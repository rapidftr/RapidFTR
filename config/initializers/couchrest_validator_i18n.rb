module CouchRest
  module Validation
    class ValidationErrors
      def self.default_error_message(key, field, *values)
        field = I18n.translate CouchRest.humanize(field), :scope => 'couchrest.fields'
        translation = I18n.translate key, :scope => 'couchrest.validations'
        translation % [field, *values].flatten
      end
    end
  end
end
