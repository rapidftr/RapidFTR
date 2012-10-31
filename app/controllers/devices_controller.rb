class DevicesController < ApplicationController
  def index
    @devices = Device.view("by_imei")
  end

  def update_blacklist
    status = 'Success'
    @devices = Device.by_imei(params[:imei])
    @devices.each do |device|
      unless device.update_attributes({:blacklisted => params[:blacklisted]})
        status = 'Failure'
      end
    end
    render :json => status
  end
end