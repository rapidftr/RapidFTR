class DevicesController < ApplicationController
  def index
    authorize! :read, Device
    @devices = Device.view("by_imei")
  end

  def update_blacklist
    authorize! :update, Device
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