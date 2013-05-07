class Session < CouchRestRails::Document
  use_database :sessions

  include RapidFTR::Model

  property :imei
  property :user_name

  view_by :user_name

  def self.for_user( user, imei)
    Session.new(
      :user_name => user.user_name,
      :imei => imei
    )
  end

  def user
    @user ||= User.find_by_user_name(user_name)
  end

  def self.get_from_cookies(cookies)
    session_id = cookies[COOKIE_KEY]
    self.get(session_id)
  end

  def self.delete_for(user)
    by_user_name(:key => user.user_name).each {|s| s.destroy }
  end

  def token
    self.id
  end

  def full_name
    user.full_name
  end

  def device_blacklisted?
    if (imei)
      return true if Device.all.any? {|device| device.imei == imei && device.blacklisted? }
    end
    false
  end

end
