class AuthorizationFailure < StandardError
  def initialize(message)
    super(message)
  end
end
