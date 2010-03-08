# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  Mime::Type.register "image/jpeg", :jpg
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_user_name
#    session = Session.by_user_name(:key=>:user_name).first
#    unless session[:user_name]
#      @current_user = nil
#      return
#    end
#    @current_user = User.find_by_user_name(session[:user_name])
#    return @current_user.user_name
    return "fix_me_to_return_session_user_name"
    end
end
