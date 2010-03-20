class Session < CouchRestRails::Document
  use_database :sessions

  property :user_name

  def self.get_from_cookies(cookies)
    session_id = cookies[:session_id]
    self.get(session_id)
  end

  def put_in_cookie(cookies)
    cookies[:session_id] = id
  end

end
