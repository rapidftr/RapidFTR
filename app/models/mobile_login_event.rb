class MobileLoginEvent < Hash
  include CouchRest::CastedModel

  property :imei
  property :mobile_number
  property :timestamp

  def initialize properties
    super(properties)
    self[:timestamp] ||= Time.now
  end
end