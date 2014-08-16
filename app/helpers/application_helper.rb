# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_url_with_format_of( format )
    url_for( params.merge( :format => format ) )
  end

  def session
    current_session
  end

  def submit_button(name = t("buttons.save"))
      submit_tag(name, :class => 'btn_submit')
  end

  def cancel_button(path)
      link_to t('cancel'), path, :class => "link_cancel", data: { confirm: t('messages.cancel_confirmation') }
  end

  def discard_button(path)
      link_to t('discard'), path, :class => 'link_discard', data: { confirm: t('messages.confirmation_message') }
  end

  def link_with_confirm(link_to, anchor, link_options = {})
    msg = nil
    confirm_message = t('messages.confirmation_message')
    if /children/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      msg = confirm_message % 'Child Record'
    elsif /user/.match(controller.controller_name) and /edit|new/.match(controller.action_name)
      msg = confirm_message % 'Users Page'
    elsif /form_section/.match(controller.controller_name) and /index/.match(controller.action_name)
       msg = confirm_message % 'Manage Form Sections'
    end

    link_options.merge data: { confirm: msg } if msg
    link_to link_to, anchor, link_options
  end

  def translated_permissions
    permissions = Permission.hashed_values.map do |group, permissions|
      [
        I18n.t(group, :scope => "permissions.group"),
        permissions.map do |permission|
          [ I18n.t(permission, :scope => 'permissions.permission'), permission ]
        end
      ]
    end
  end

end
