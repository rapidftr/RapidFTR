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

    def logged_in?
      request && current_session && current_user
    end

    def check_authentication
      raise AuthenticationFailure.new(I18n.t("session.has_expired")) unless logged_in?
    end

  end
end
