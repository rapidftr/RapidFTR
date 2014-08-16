class MobileLoginEvent
  include CouchRest::Model::CastedModel

  property :imei
  property :mobile_number
  property :timestamp, Time, :init_method => 'parse'

  def initialize(properties)
    super(properties)
    self[:timestamp] ||= Clock.now
  end
end
