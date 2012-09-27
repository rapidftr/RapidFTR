class MobileLoginEvent
  include CouchRest::Model::Embeddable
  property :imei
  property :mobile_number
  property :timestamp, Time

  def initialize properties
    super(properties)
    self[:timestamp] ||= Time.now.utc
  end
end
