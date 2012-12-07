# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_url_with_format_of( format )
    url_for( params.merge( 'format' => format, 'escape' => false ) )
  end

  # TODO Remove duplication in ApplicationController
  def current_user_name
    return current_user.try(:user_name)
  end

  def render_nav_bar?
    current_user_name != nil
  end

  def session
    Session.get_from_cookies(cookies)
  end

  def current_user
    session.try(:user)
  end

  def is_admin?
    current_user.has_permission?(Permission::ADMIN[:admin]) if current_user
  end

  def submit_button(name = 'Save')
      submit_tag(name, :class => 'btn_submit')
  end

  def cancel_button(path)
      link_to 'Cancel', path, :confirm => 'Are you sure you want to cancel?', :class => "link_cancel"
  end

  def discard_button(path)
      link_to 'Discard', path, :confirm => 'Clicking OK Will Discard Any Unsaved Changes. Click Cancel To Return To The Child Record Instead.', :class => 'link_discard'
  end

  def show_sidebar_links
    sidebar_links = {"View All Children" => children_path,
                     "Search" => search_children_path,
                     "Advanced Search" => new_advanced_search_path}
    sidebar_links.select do |_, link|
      !current_page?(link)
    end
  end

  def link_with_confirm(link_to, anchor, link_options = {})
    link_options.merge!(link_confirm_options(controller))
    link_to link_to, anchor, link_options
  end

  def link_confirm_options(controller)
    confirm_options = { }
    confirm_message = 'Clicking OK Will Discard Any Unsaved Changes. Click Cancel To Return To The %s Instead.'
    if /children/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      confirm_options[:confirm] = confirm_message % 'Child Record'
    elsif /user/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      confirm_options[:confirm] = confirm_message % 'Users Page'
    elsif /form_section/.match(controller.controller_name) and /index/.match(controller.action_name)
       confirm_options[:confirm] = confirm_message % 'Manage Form Sections'
    end
    confirm_options
  end



end
