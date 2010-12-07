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

    #Session.new(:user_name => @user_name)
    session = Session.for_user( user ) unless user.nil? or !user.authenticate(@password)

    if session and @imei
      user.add_mobile_login_event(@imei, @mobile_number)
      user.save
    end


    session
  end

  def errors
    @errors ||= Errors.new
  end
end
