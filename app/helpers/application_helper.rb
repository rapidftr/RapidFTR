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

  def submit_button(name = 'Save')
    content_tag(:p, :class => 'submitButton') do
      submit_tag(name)
    end
  end

  def cancel_button(path)
    content_tag(:p, :class => 'cancelButton') do
      link_to 'Cancel', path, :confirm => 'Are you sure you want to cancel?'
    end
  end

  def discard_button(path)
    content_tag(:p, :class => 'discardButton') do
      link_to 'Discard', path, :confirm => 'Clicking OK Will Discard Any Unsaved Changes. Click Cancel To Return To The Child Record Instead.'
    end
  end
end
