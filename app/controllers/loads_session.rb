module LoadsSession

  def logged_in?
    !get_session.nil? unless request.nil?
  end

  private

  def get_session
    token = token_from_request
    return nil if token.nil?
    Session.get(token_from_request)
  end

  def token_from_request
    pull_token_from_headers || pull_token_from_cookies
  end

  def pull_token_from_headers
    authorization_header = request.headers['Authorization']
    return nil if authorization_header.nil?
    authorization_header[/^RFTR_Token (.*)/, 1]
  end

  def pull_token_from_cookies
    cookies[Session::COOKIE_KEY]
  end

end
