class DevicesController < ApplicationController
  def index
    @devices = Device.view("by_user_name")
  end
end