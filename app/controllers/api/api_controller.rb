require "active_support/json/backends/okjson"

class Api::ApiController < ActionController::Base

  include Security::Authentication

  before_filter :extend_session_lifetime
  before_filter :check_authentication
  before_filter :check_device_blacklisted
  before_filter :current_user

  private

  rescue_from(Exception) { |e| render_exception e }
  rescue_from(AuthenticationFailure) { |e| render_error_response ErrorResponse.unauthorized e.message }
  rescue_from(CanCan::AccessDenied) { |e| render_error_response ErrorResponse.forbidden e.message }
  rescue_from(ErrorResponse) { |e| render_error_response e }
  rescue_from(ActiveSupport::OkJson::Error) {|e| malformed_json(e) }

  def check_device_blacklisted
    raise ErrorResponse.forbidden("Device Blacklisted") if current_session && current_session.device_blacklisted?
  end

  def render_error_response(e)
    render :status => e.status_code, :json => e.message
  end

  def render_exception(e)
    render :status => 500, :json => e.message
  end

  def extend_session_lifetime
    request.env[ActionDispatch::Session::AbstractStore::ENV_SESSION_OPTIONS_KEY][:expire_after] = 1.week
  end

  def malformed_json(e)
    render :status => 422, :json => "Invalid request"
  end

end
