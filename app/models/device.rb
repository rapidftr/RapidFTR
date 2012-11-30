class Device < CouchRestRails::Document
  use_database :device
  
  include RapidFTR::Model
  
  property :imei
  property :blacklisted, :cast_as => :boolean
  property :user_name

  before_save :set_appropriate_data_type

  def self.find_by_imei(imei)
    Device.by_imei(:key => imei)
  end

  def set_appropriate_data_type
    self.blacklisted = self.blacklisted == "true" if self.blacklisted.is_a? String
    self.imei = self.imei.to_s
  end

  view_by :imei

end