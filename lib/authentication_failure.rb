class AuthenticationFailure < StandardError
  def self.no_token(message)
    new(false,message)
  end

  def self.bad_token(message)
    new(true,message)
  end

  def initialize(token_provided,message)
    super(message)
    @token_provided = token_provided
  end

  def token_provided?
    @token_provided
  end
end
