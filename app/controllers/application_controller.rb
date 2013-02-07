# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_user_name, :current_user, :current_user_full_name, :current_session, :logged_in?

  include ChecksAuthentication
  before_filter :check_authentication
  before_filter :set_locale

  rescue_from( AuthenticationFailure ) { |e| handle_authentication_failure(e) }
  rescue_from( AuthorizationFailure ) { |e| handle_authorization_failure(e) }
  rescue_from( ErrorResponse ) { |e| render_error_response(e) }
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end
  def render_error_response(ex)
    @exception = ex

    # Only add the error page to the status code if the request-format was HTML
    respond_to do |format|
      format.html do
        render(
          :template => "shared/status_#{ex.status_code.to_s}",
          :status => ex.status_code
        )
      end
      format.any(:xml,:json) do
        begin
        render(
          :template => "shared/status_#{ex.status_code.to_s}",
          :status => ex.status_code
        )
        rescue ActionView::MissingTemplate
          head ex.status_code # only return the status code
        end
      end
    end
  end

  # TODO Remove duplication in ApplicationHelper
  def current_user_name
    current_user.try(:user_name)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def current_user_full_name
    current_user.try(:full_name)
  end

  def current_user
    @current_user ||= current_session.try(:user)
  end

  def current_session
    @current_session ||= get_session
  end

  def logged_in?
    !current_session.nil? unless request.nil?
  end

  def send_pdf(pdf_data,filename)
    send_data pdf_data, :filename => filename, :type => "application/pdf"
  end

  def name
    self.class.to_s.gsub("Controller", "")
  end

  def session_expiry
    session = current_session
    unless session.nil?
      if session.expired?
        flash[:error] = 'Your session has expired. Please re-login.'
        redirect_to logout_path
      end
    end
  end

  def update_activity_time
    session = current_session
    unless session.nil?
      session.update_expiration_time(20.minutes.from_now)
      session.save
    end
  end

  def set_locale
    I18n.locale = params[:locale] || cookies[:locale] || I18n.default_locale
  end

  def clean_params(param)
    param.reject{|value| value.blank?}
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    %(<span class="field-error">) + html_tag + %(</span>)
  end
end
