class Session < CouchRestRails::Document
  use_database :sessions

  property :user
  property :expires_at, :cast_as => 'Time', :init_method => 'parse'

  view_by :user_name

  COOKIE_KEY = 'rftr_session_token'

  def self.for_user( user )
    Session.new(
      :user_name => user.user_name,
      :user => user.clone.except("password")
    )
  end

  def self.get_from_cookies(cookies)
    session_id = cookies[COOKIE_KEY]
    self.get(session_id)
  end

  def self.remove_from_cookies(cookies)
    cookies.delete(COOKIE_KEY)
  end

  def self.delete_for(user)
    by_user_name(:key => user.user_name).each {|s| s.destroy }
  end

  def put_in_cookie(cookies)
    cookies[COOKIE_KEY] = id
  end

  def token
    self.id
  end

  def user_name
    user['user_name']
  end
  
  def full_name
    user['full_name']
  end

  def expired?
    return true if !expiration_time.nil? && expiration_time - Time.now <= 0
    false
  end

  def will_expire_soon?
    return true if !expiration_time.nil? && expiration_time - Time.now <= 5.minutes
    false
  end

  def update_expiration_time(time)
    self[:expires_at] = time
  end

  def expiration_time
    self[:expires_at]
  end

end
