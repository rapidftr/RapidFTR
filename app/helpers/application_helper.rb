# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_url_with_format_of( format )
    url_for( params.merge( 'format' => format, 'escape' => false ) )
  end

  # TODO Remove duplication in ApplicationController
  def current_user_name
    session = Session.get_from_cookies(cookies)
    return session.user_name unless session.nil? or session.user.nil?
  end
end
