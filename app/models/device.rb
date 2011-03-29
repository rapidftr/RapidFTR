class Device < Hash
  include CouchRest::CastedModel

  property :imei
  property :blacklisted, :cast_as => :boolean
  
  

end