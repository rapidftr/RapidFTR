class Device < CouchRest::Model::Base
  use_database :device

  include RapidFTR::Model
  include RapidFTR::CouchRestRailsBackward

  property :imei
  property :blacklisted, TrueClass
  property :user_name

  before_save :set_appropriate_data_type

  # Don't change the name to find_by_imei this will
  # conflict with the corresponding Dynamic finder.
  def self.find_by_device_imei(imei)
    Device.by_imei(:key => imei)
  end

  def set_appropriate_data_type
    self.blacklisted = blacklisted == "true" if blacklisted.is_a? String
    self.imei = imei.to_s
  end

  design do
    view :by_imei
  end
end
