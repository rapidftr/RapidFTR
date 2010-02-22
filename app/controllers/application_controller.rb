# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  Mime::Type.register "image/jpeg", :jpg
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def self.current_user
    user = User.new
    user.user_name = 'zubair'
    user
  end
  def current_user_name
     return "fix_me_to_return_session_user_name"
  end
end
