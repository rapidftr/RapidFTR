class HomeController < ApplicationController

  def index
    @page_name = "Home"
    @user = User.find_by_user_name(current_user_name)
    @notifications = PasswordRecoveryRequest.to_display
  end
end