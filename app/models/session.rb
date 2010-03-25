class Session < CouchRestRails::Document
  use_database :sessions

  property :user

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
  
end
