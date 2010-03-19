# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  Mime::Type.register "image/jpeg", :jpg

  before_filter :check_authentication

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password


  rescue_from( ErrorResponse ) { |e| render_error_response(e) }
 
  def render_error_response(ex)
    @exception = ex
 
    # Only add the error page to the status code if the reuqest-format was HTML
    respond_to do |format|
      format.html do
        render( 
          :template => "shared/status_#{ex.status_code.to_s}",
          :status => ex.status_code 
        )
      end
      format.any  { head ex.status_code } # only return the status code
    end
  end


  def self.current_user
    user = User.new
    user.user_name = 'zubair'
    user
  end

  def current_user_name
    session = Session.get_from_cookies(cookies)
    if not session
      return nil
    end
    return session.user_name
  end

  def check_authentication
    return if self.controller_name == 'sessions'

    unless Session.get_from_cookies(cookies)
      redirect_to :login
    end
  end

  def send_pdf(pdf_data,filename) 
    send_data pdf_data, :filename => filename, :type => "application/pdf"
  end

  def name
    self.class.to_s.gsub("Controller", "")
  end
end
