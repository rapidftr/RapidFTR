class DevicesController < ApplicationController
  def index
    @page_name = t("devices")
    if can? :read, Replication
      @replications = Replication.all
    end
    if can? :read, Device
      @devices = Device.view("by_imei")
    end
  end

  def update_blacklist
    authorize! :update, Device
    status = :ok
    @devices = Device.find_by_device_imei(params[:imei])
    @devices.each do |device|
      unless device.update_attributes(:blacklisted => params[:blacklisted] == "true")
        status = :error
      end
    end
    render :json => {:status => status}
  end
end
