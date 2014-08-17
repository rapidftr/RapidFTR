class Login
  include Validatable
  attr_accessor :errors
  attr_accessor :user_name
  attr_accessor :password

  def initialize(params)
    @user_name = params[:user_name]
    @password = params[:password]
    @imei = params[:imei]
    @mobile_number = params[:mobile_number]
  end

  def authenticate_user
    user = User.find_by_user_name(@user_name)
    if user && user.authenticate(@password)
      mobile_login_history = user.mobile_login_history.first
      imei = mobile_login_history.nil? ? "" : mobile_login_history['imei']
      session = user.verified ? Session.for_user(user, @imei) : ((imei == @imei) || (imei == "") ? Session.for_user(user, @imei) : nil)
    end

    if session && @imei
      user.add_mobile_login_event(@imei, @mobile_number)
      user.save
    end

    session
  end

  def errors
    @errors ||= Errors.new
  end
end
