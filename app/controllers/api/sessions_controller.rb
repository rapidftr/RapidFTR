module Api
  class SessionsController < ApiController
    skip_before_action :check_authentication, :check_device_blacklisted, :only => [:login, :register]

    def login
      @login = Login.new(params)
      @current_session = @login.authenticate_user

      fail ErrorResponse.unauthorized("session.invalid_credentials") unless @current_session
      check_device_blacklisted

      @current_session.save!
      session[:rftr_session_id] = @current_session.id
      session[:last_access_time] = Clock.now.rfc2822
      render_session_as_json @current_session
    end

    def logout
      current_session.try :destroy
      render :json => true
    end

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

      render :json => {:response => "ok"}
    end

    private

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
end
