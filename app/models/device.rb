class Device < CouchRestRails::Document
  use_database :device
  
  property :imei
  property :blacklisted, :cast_as => :boolean
  property :user_name
  
end