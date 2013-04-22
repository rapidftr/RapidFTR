class Api::SessionsController < Api::ApiController

  skip_before_filter :check_authentication, :check_device_blacklisted, :only => [ :login, :register ]

  # @api_cleanup
  # TODO:
  # Once Old API is cleaned up
  # Remove "login when json?" in Web sessions_controller
  # Remove this SessionModule
  # Have all methods inside this SessionModule directly in this controller itself

  module SessionModule
    def login
      @login = Login.new(params)
      @current_session = @login.authenticate_user

      raise ErrorResponse.unauthorized(t("session.invalid_credentials")) unless @current_session
      check_device_blacklisted

      @current_session.save!
      session[:rftr_session_id] = @current_session.id
      render_session_as_json @current_session
    end

    def logout
      current_session.try :destroy
      render :json => true
    end

    private

    # This method is already there in ApiController
    # It has been duplicated here since it is being re-used in the Old API
    # This is no longer required here when we remove the old API
    def check_device_blacklisted
      raise ErrorResponse.forbidden("Device Blacklisted") if current_session && current_session.device_blacklisted?
    end

    def render_session_as_json(session)
      user = User.find_by_user_name(session.user_name)
      json = {
        :db_key => mobile_db_key(session.imei),
        :organisation => user.organisation,
        :language => I18n.default_locale,
        :verified => user.verified?
      }

      render :json => json, :status => 201
    end

    def mobile_db_key(imei)
      MobileDbKey.find_or_create_by_imei(imei).db_key
    end
  end

  include SessionModule

  def register
    user = params[:user]
    user = JSON.parse user if user.is_a? String

    if User.find_by_user_name(user["user_name"]).nil?
      password = user["unauthenticated_password"]
      updated_params = user.merge(:verified => false, :password => password, :password_confirmation => password)
      updated_params.delete("unauthenticated_password")
      user = User.new(updated_params)
      user.save!
    end

    render :json => {:response => "ok"}.to_json
  end

end
