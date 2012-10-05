# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include ChecksAuthentication

  before_filter :check_authentication
  rescue_from( AuthenticationFailure ) { |e| handle_authentication_failure(e) }
  rescue_from( AuthorizationFailure ) { |e| handle_authorization_failure(e) }

  rescue_from( ErrorResponse ) { |e| render_error_response(e) }

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
    session = app_session
    return session.user_name unless session.nil?
  end

  def current_user_full_name
    session = Session.get_from_cookies(cookies)
    session.user['full_name'] unless session.nil? or session.user.nil?
  end

  def current_user
    @user ||= User.find_by_user_name(current_user_name)
  end

  def send_pdf(pdf_data,filename) 
    send_data pdf_data, :filename => filename, :type => "application/pdf"
  end

  def name
    self.class.to_s.gsub("Controller", "")
  end

  def session_expiry
    session = get_session
    unless session.nil?
      if session.expired?
        flash[:error] = 'Your session has expired. Please re-login.'
        redirect_to logout_path
      end
    end
  end

  def update_activity_time
    session = get_session
    unless session.nil?
      session.update_expiration_time(20.minutes.from_now)
      session.save
    end
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    %(<span class="field-error">) + html_tag + %(</span>)
  end
end
