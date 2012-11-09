class DevicesController < ApplicationController
  def index
    authorize! :read, Device
    @devices = Device.view("by_imei")
  end

  def update_blacklist
    authorize! :update, Device
    status = :ok
    @devices = Device.by_imei(:key => params[:imei].to_i)
    @devices.each do |device|
      unless device.update_attributes({:blacklisted => params[:blacklisted]})
        status = :error
      end
    end
    render :json => {:status => status}
  end
end