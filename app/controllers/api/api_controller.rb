class Api::ApiController < ActionController::Base

  include Security::Authentication

  before_filter :check_authentication
  before_filter :check_device_blacklisted
  before_filter :extend_session_lifetime
  before_filter :current_user

  private

  rescue_from(Exception) { |e| render_exception e }
  rescue_from(AuthenticationFailure) { |e| render_error_response ErrorResponse.unauthorized e.message }
  rescue_from(CanCan::AccessDenied) { |e| render_error_response ErrorResponse.forbidden e.message }
  rescue_from(ErrorResponse) { |e| render_error_response e }
  rescue_from(ActiveSupport::JSON.parse_error) { |e| malformed_json(e) }

  def check_device_blacklisted
    raise ErrorResponse.forbidden("Device Blacklisted") if current_session && current_session.device_blacklisted?
  end

  def restrict_to_test
    raise ErrorResponse.unauthorized("Unauthorized Operation") unless Rails.env.android?
  end

  def render_error_response(e)
    render :status => e.status_code, :json => e.message
  end

  def render_exception(e)
    render :status => 500, :json => e.message
  end

  def extend_session_lifetime
    session[:last_access_time] = Clock.now.rfc2822
  end

  def malformed_json(e)
    render :status => 422, :json => I18n.t("errors.models.enquiry.malformed_query")
  end

  def sanitize_params(object)
    params[object.to_sym] = JSON.parse(params[object.to_sym]) if params[object.to_sym].is_a?(String)
  end

end
