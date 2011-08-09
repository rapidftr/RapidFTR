class PasswordRecoveryRequestsController < ApplicationController

  skip_before_filter :check_authentication
  # GET /children/new
  # GET /children/new.xml
  def new

    @password_recover_request = PasswordRecoveryRequest.new({})
  end

  def create
    @password_recover_request = PasswordRecoveryRequest.new(params[:password_recovery_request])
    if @password_recover_request.save
      flash.now[:notice] = "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."
    else
      render :new
    end

  end
end
