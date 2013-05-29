class Login
  include Validatable
  attr_accessor :errors
  attr_accessor :user_name
  attr_accessor :password

  LOCKOUT_OPTIONS = {
    :lockout_period => 1, # in minutes
    :maximum_attempts => 3 # can have x number of login_attempts in this many minutes
  }

  def initialize(params)
    @user_name = params[:user_name]
    @password = params[:password]
    @imei = params[:imei]
    @mobile_number = params[:mobile_number]
  end

  def authenticate_user
    user = User.find_by_user_name(@user_name)
    if(user.nil?)
      return [nil, -1]
    end

    if (user.failed_attempts == LOCKOUT_OPTIONS[:maximum_attempts])
      if ((Time.now - Time.parse(user.lock_time))/60 < LOCKOUT_OPTIONS[:lockout_period])
        return [nil, user.failed_attempts]
      else
        unlock_user_account(user)
      end
    end

    if (user.authenticate(@password))
      mobile_login_history = user.mobile_login_history.first
      imei = mobile_login_history.nil? ? "" : mobile_login_history['imei']
      session = user.verified ? Session.for_user(user, @imei) : ((imei == @imei) || (imei == "") ? Session.for_user(user, @imei) : nil)
      unlock_user_account(user)
    else
      if (user.failed_attempts != 0 and (Time.now - Time.parse(user.last_failed_time))/60 > LOCKOUT_OPTIONS[:lockout_period])
        user.failed_attempts = 1;
        user.lock_time = nil;
      else
        user.failed_attempts += 1;
        if (user.failed_attempts == LOCKOUT_OPTIONS[:maximum_attempts])
          user.lock_time = Time.now
        end
      end
      user.last_failed_time = Time.now
    end

    if session and @imei
      user.add_mobile_login_event(@imei, @mobile_number)
    end
    user.save

    failed_attempts = user.nil? ? -1 : user.failed_attempts
    [session, failed_attempts]
  end

  def unlock_user_account(user)
    user.failed_attempts = 0;
    user.lock_time = nil;
    user.last_failed_time = nil
  end

  def errors
    @errors ||= Errors.new
  end
end
