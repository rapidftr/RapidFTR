class Login
  include Validatable
  attr_accessor :errors

  def initialize(params)
    @user_name = params[:user_name]
    @password = params[:password]
  end

  def autheniticate_user
    authenticated = !User.find_by_user_name(@user_name).nil?

    if not authenticated
      errors.add("user_name", "User does not exist")
    end

    authenticated
  end

  def errors
    @errors ||= Errors.new
  end
end