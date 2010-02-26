class Login
  include Validatable
  attr_accessor :errors

  def initialize(params)
    @user_name = params[:user_name]
    @password = params[:password]
  end

  def autheniticate_user
    user = User.find_by_user_name(@user_name)

    authenticated = !user.nil? && user.autheticate(@password)

    if not authenticated
      errors.add(:base, "Invalid credentials. Please try again!")
    end

    authenticated
  end

  def errors
    @errors ||= Errors.new
  end
end