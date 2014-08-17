class PasswordRecoveryRequestsController < ApplicationController
  skip_before_action :check_authentication

  def new
    @password_recovery_request = PasswordRecoveryRequest.new
  end

  def create
    @password_recovery_request = PasswordRecoveryRequest.new params[:password_recovery_request]
    respond_to do |format|
      if @password_recovery_request.save
        success_notice = t("login.password.success_notice")
        format.html do
          flash[:notice] = success_notice
          redirect_to login_path
        end
        format.json { render :json => password_recovery_json(success_notice), :status => :ok }
      else
        format.html { render :new }
        format.json { render :json => password_recovery_json(@password_recovery_request.errors.full_messages.join('. ')), :status => :ok }
      end
    end
  end

  def hide
    PasswordRecoveryRequest.get(params[:password_recovery_request_id]).hide!
    flash[:notice] = t('login.password.successfully_hidden')
    redirect_to root_path
  end

  private

  def password_recovery_json(notice)
    {
      :response => notice
    }
  end
end
