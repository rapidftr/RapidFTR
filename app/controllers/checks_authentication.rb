module ChecksAuthentication

  private

  def app_session
    token = pull_token_from_headers || pull_token_from_cookies
    raise AuthenticationFailure.no_token('no session token in headers or cookies') if token.blank?
    session = Session.get(token)
  end

  # a before filter requiring user to be logged in
  def check_authentication
    session = app_session
    raise AuthenticationFailure.bad_token('invalid session token') if session.nil?
    session
  end

  # a before filter requiring user to be an admin
  def administrators_only
     session = app_session
     raise AuthorizationFailure.new('Not permitted to view page') unless session.admin?
  end 

  def pull_token_from_headers
    authorization_header = request.headers['Authorization']
    return nil if authorization_header.nil?
    authorization_header[/^RFTR_Token (.*)/,1]
  end

  def pull_token_from_cookies
    cookies[Session::COOKIE_KEY]
  end

  def handle_authentication_failure(auth_failure)
    if auth_failure.token_provided?
      render_error_response ErrorResponse.unauthorized("invalid session token")
    else
      respond_to do |format|
        format.html{ redirect_to(:login ) }
        format.any{ render_error_response ErrorResponse.unauthorized("no session token provided") }
      end
    end
  end

  def handle_authorization_failure(authorization_failure)
    respond_to do |format|
      format.any{ render_error_response ErrorResponse.new(403, authorization_failure.message) }
    end
  end
end
