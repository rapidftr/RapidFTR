class Login
  include Validatable
  attr_accessor :errors
  attr_accessor :user_name
  attr_accessor :password


  def initialize(params)
    @user_name = params[:user_name]
    @password = params[:password]
  end

  def authenticate_user
    user = User.find_by_user_name(@user_name)

    if user.nil? || !user.authenticate(@password)
      errors.add(:base, "Invalid credentials. Please try again!")

      return nil
    end

    #Session.new(:user_name => @user_name)
    Session.for_user( user )
  end

  def errors
    @errors ||= Errors.new
  end
end
