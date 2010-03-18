class ErrorResponse < StandardError
  attr_reader :status_code
  attr_reader :status_text

  def self.bad_request(message)
    new( 400, message )
  end

  def initialize( status_code, message )
    @status_code = status_code
    super(message)
  end

  def status_text
    ActionController::StatusCodes::STATUS_CODES[status_code]
  end
end
