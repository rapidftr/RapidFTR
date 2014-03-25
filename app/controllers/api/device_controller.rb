class Api::DeviceController < Api::ApiController

  skip_before_filter :check_device_blacklisted
  skip_before_filter :check_authentication

  def is_blacklisted
    device = Device.find_by_device_imei(params[:imei]).first
    if device
      render :json => { :blacklisted => device.blacklisted }
    else
      render :json => { :error => "Not found" }, :status => 404
    end
  end
end
