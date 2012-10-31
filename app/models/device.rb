class Device < CouchRestRails::Document
  use_database :device
  
  include RapidFTR::Model
  
  property :imei
  property :blacklisted, :cast_as => :boolean
  property :user_name

  view_by :imei

end