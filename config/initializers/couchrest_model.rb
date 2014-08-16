#Configure for compatibility with older version.
#Current model_type_key is 'type', older is 'couchrest-type'
CouchRest::Model::Base.configure do |config|
  config.mass_assign_any_attribute = true
  config.model_type_key = 'couchrest-type'
end

#This is a monkeypatch to set the dirty flag for arbitrary attributes when mass assignment is turned on.
#Couchrest_model is using the inherited []= setter which fails to set the flag.
#See: https://github.com/couchrest/couchrest_model/issues/114
#See: https://github.com/couchrest/couchrest_model/issues/130
#TODO: Still a hack, doesn't cover the model['foo']['bar']='value' case.
module CouchRest
  module Model
    class Base
      alias_method :set_a_value, :[]=
      def []=(key, value)
        prev_value = self[key]
        changed_attributes[key] = prev_value
        set_a_value key, value
      end
      #TODO: what about overriding the delete method?

      # Another monkey patch to get the old "save_without_callbacks" behavior
      def save_without_callbacks
        if valid?
          result = database.save_doc(self)
          ret = result["ok"] == true
          @changed_attributes.clear if ret && @changed_attributes
          ret
        end
      end
    end
  end
end

#couchrest 0.34
#CouchRest::CastedModel did not provide "to_key" method.
#
#couchrest 1.1.3 defined the module CouchRest::Model::Embeddable
#as the new way to define CastedModel, this class define the
#method "to_key" which returns the the id, but
#actionpack-4.0.3/lib/action_view/record_identifier.rb needs the
#return value as a Enumerable type such an array.
#
#The following solve the issue in /form_section/ when edit fields.
module CouchRest
  module Model
    module Embeddable
      def to_key
        key = respond_to?(:id) && id
        key ? [key] : nil
      end
    end
  end
end
