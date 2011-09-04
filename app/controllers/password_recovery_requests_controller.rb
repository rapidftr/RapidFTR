class PasswordRecoveryRequestsController < ApplicationController

  skip_before_filter :check_authentication

  def new
    @password_recover_request = PasswordRecoveryRequest.new
  end

  def create
    if PasswordRecoveryRequest.create params[:password_recovery_request]
      flash.now[:notice] = "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."
    else
      render :new
    end
  end

  def hide
    PasswordRecoveryRequest.get(params[:password_recovery_request_id]).hide!
    flash[:notice] = 'Password request notification was succefully hidden.'
    redirect_to root_path
  end
end
