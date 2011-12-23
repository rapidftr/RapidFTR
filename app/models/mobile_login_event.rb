class MobileLoginEvent < Hash
  include CouchRest::CastedModel

  property :imei
  property :mobile_number
  property :timestamp, :cast_as => 'Time', :init_method => 'parse' 

  def initialize properties
    super(properties)
    self[:timestamp] ||= Clock.now
  end
end
