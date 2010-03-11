class Session < CouchRestRails::Document
  use_database :sessions

  property :user_name

  def autheniticate_user
    user = User.find_by_user_name(@user_name)

    authenticated = !user.nil? && user.autheticate(@password)

    if not authenticated
      errors.add(:base, "Invalid credentials. Please try again!")
    end

    authenticated
  end

  def self.get_from_cookies(cookies)
    session_id = cookies[:session_id]
    self.get(session_id)
  end

  def put_in_cookie(cookies)
    cookies[:session_id] = id
  end

end
