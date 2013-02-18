module ChecksAuthentication

  include LoadsSession

  private

  def app_session
    token = token_from_request
    raise AuthenticationFailure.no_token(t("session.no_token_in_header")) if token.blank?
    get_session
  end

  # a before filter requiring user to be logged in
  def check_authentication
    session = app_session
    handle_device_blacklisted(session) if session && session.device_blacklisted?
    raise AuthenticationFailure.bad_token(t("session.invalid_token")) if session.nil?
  end

  def handle_authentication_failure(auth_failure)
    if auth_failure.token_provided?
      Session.remove_from_cookies cookies
      render_error_response ErrorResponse.unauthorized(t("session.invalid_token"))
    else
      respond_to do |format|
        format.html { redirect_to(:login) }
        format.any(:xml,:json) { render_error_response ErrorResponse.unauthorized(t("session.no_token_provided")) }
      end
    end
  end

  def handle_authorization_failure(authorization_failure)
    respond_to do |format|
      format.any { render_error_response ErrorResponse.new(403, authorization_failure.message) }
    end
  end

  def handle_device_blacklisted(session)
    render(:status => 403, :json => session.imei)
  end
end
