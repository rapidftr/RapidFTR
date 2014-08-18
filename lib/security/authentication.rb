module Security
  module Authentication
    def current_session
      @current_session ||= Session.get current_token rescue nil
    end

    def current_user
      @current_user ||= current_session.try(:user)
    end

    def current_user_name
      current_user.try(:user_name)
    end

    def current_user_full_name
      current_user.try(:full_name)
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def current_token
      session[:rftr_session_id] rescue nil
    end

    def session_expiry_timeout
      Rails.application.config.session_options[:rapidftr][:web_expire_after]
    end

    def session_expired?
      (session_expiry_timeout.ago(Clock.now) > DateTime.parse(session[:last_access_time])) rescue true
    end

    def logged_in?
      request && !session_expired? && current_session && current_user
    end

    # TODO: Rename to check_expiry or logged_in! something
    def check_authentication
      logged_in? || fail(ErrorResponse.unauthorized("session.has_expired"))
    end
  end
end
