class Device < CouchRest::Model::Base
  use_database :device

  property :imei
  property :blacklisted, TrueClass
  property :user_name

end
