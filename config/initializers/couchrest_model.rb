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
module CouchRest
  module Model
    class Base
      alias :set_a_value :[]=
      def []=(key, value)
        prev_value = self[key]
        changed_attributes[key] = prev_value
        set_a_value key, value
      end
      #TODO: what about overriding the delete method?
    end
  end
end
