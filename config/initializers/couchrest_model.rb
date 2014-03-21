#Configure for compatibility with older version.
#Current model_type_key is 'type', older is 'couchrest-type'
CouchRest::Model::Base.configure do |config|
  config.mass_assign_any_attribute = true
  config.model_type_key = 'couchrest-type'
end
