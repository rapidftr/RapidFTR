#Configure for compatibility with older version.
#Current model_type_key is 'type', older is 'couchrest-type'
CouchRest::Model::Base.configure do |config|
  config.model_type_key = 'couchrest-type'
end
