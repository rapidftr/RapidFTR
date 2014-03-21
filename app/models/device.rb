class Device < CouchRest::Model::Base
  use_database :device

  include RapidFTR::Model

  property :imei
  property :blacklisted, TrueClass
  property :user_name

  before_save :set_appropriate_data_type

  def self.find_by_imei(imei)
    Device.by_imei(:key => imei)
  end

  def set_appropriate_data_type
    self.blacklisted = self.blacklisted == "true" if self.blacklisted.is_a? String
    self.imei = self.imei.to_s
  end

  design do
    view :by_imei
  end

end