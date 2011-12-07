class PasswordRecoveryRequestsController < ApplicationController

  skip_before_filter :check_authentication

  def new
    @password_recover_request = PasswordRecoveryRequest.new
  end

  def create
    success_notice = "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."
    failure_notice =  "This user name does not exist. Please try again."
    respond_to do |format|
      if is_valid_user and PasswordRecoveryRequest.create params[:password_recovery_request]
        format.html { flash.now[:notice] = success_notice }
        format.json { render :json => password_recovery_json(success_notice) , :status => :ok, :head => :ok}
      else
        format.html { flash[:error] = failure_notice
                      redirect_to :action => "new"
        }
        format.json { render :json => password_recovery_json(failure_notice) , :status => :ok}
      end
    end
  end

  def hide
    PasswordRecoveryRequest.get(params[:password_recovery_request_id]).hide!
    flash[:notice] = 'Password request notification was successfully hidden.'
    redirect_to root_path
  end

  private
  def is_valid_user
    !params[:password_recovery_request][:user_name].blank? and User.find_by_user_name(params[:password_recovery_request][:user_name])
  end

  def password_recovery_json(notice)
    {
        :response => notice
    }
  end

end
