class ErrorResponse < StandardError
  attr_reader :status_code

  def self.bad_request(message)
    new(400, message)
  end

  def self.unauthorized(message)
    new(401, message)
  end

  def self.forbidden(message)
    new(403, message)
  end

  def self.not_found(message)
    new(404, message)
  end

  def self.internal_server_error(message)
    new(500, message)
  end

  def self.log(exception)
    return unless (logger = Rails.logger)

    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << '  ' << (exception.backtrace || []).join("\n  ")
    logger.fatal("#{message}\n\n")
  end

  def initialize(status_code, message)
    @status_code = status_code
    super(I18n.t(message))
  end

  def status_text
    Rack::Utils::HTTP_STATUS_CODES[status_code]
  end
end
