# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include LoadsSession

  def current_url_with_format_of( format )
    url_for( params.merge( 'format' => format, 'escape' => false ) )
  end

  # TODO Remove duplication in ApplicationController
  def current_user_name
    return current_user.try(:user_name)
  end

  def session
    get_session
  end

  def current_user
    session.try(:user)
  end

  def submit_button(name = t("buttons.save"))
      submit_tag(name, :class => 'btn_submit')
  end

  def cancel_button(path)
      link_to t('cancel'), path, :confirm => t('messages.cancel_confirmation'), :class => "link_cancel"
  end

  def discard_button(path)
      link_to t('discard'), path, :confirm => t('messages.confirmation_message'), :class => 'link_discard'
  end

  def link_with_confirm(link_to, anchor, link_options = {})
    link_options.merge!(link_confirm_options(controller))
    link_to link_to, anchor, link_options
  end

  def link_confirm_options(controller)
    confirm_options = { }
    confirm_message = t('confirmation_message')
    if /children/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      confirm_options[:confirm] = confirm_message % 'Child Record'
    elsif /user/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      confirm_options[:confirm] = confirm_message % 'Users Page'
    elsif /form_section/.match(controller.controller_name) and /index/.match(controller.action_name)
       confirm_options[:confirm] = confirm_message % 'Manage Form Sections'
    end
    confirm_options
  end

  def translated_permissions
    Permission.hashed_values.map do |group, permissions|
      [
          I18n.t(group, :scope => "permissions.group"),
          permissions.map do |permission|
            [ I18n.t(permission, :scope => 'permissions.permission'), permission ]
          end
      ]
    end
  end

end
