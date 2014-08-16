class DeviceListPage

  def initialize(session)
    @session = session
  end

  def blacklist_device(imei)
    @session.find_by_id("#{imei}").click
    @session.click_button('Yes')
  end
end
