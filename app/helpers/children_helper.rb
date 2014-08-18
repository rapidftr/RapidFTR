module ChildrenHelper

  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  module EditView
    ONETIME_PHOTOS_UPLOAD_LIMIT = 5
  end
  ORDER_BY = {'active' => 'created_at', 'all' => 'created_at', 'reunited' => 'reunited_at', 'flag' => 'flag_at'}

  def thumbnail_tag(child, key = nil)
    image_tag(child_thumbnail_path(child, key || child.current_photo_key, :ts => child.last_updated_at), :alt => child['name'])
  end

  def link_to_photo_with_key(key)
    link_to thumbnail_tag(@child, key),
            child_photo_path(@child, key, :ts => @child.last_updated_at),
            :id => key,
            :target => '_blank'
  end

  def link_to_download_audio_with_key(key)
    link_to key.humanize, child_audio_url(@child.id, key), :id => key, :target => '_blank'
  end

  def is_playable_in_browser(audio)
    AudioMimeTypes.browser_playable? audio.mime_type
  end

  def link_to_update_info(child)
    link_to('and others', child_history_path(child)) unless child.has_one_interviewer?
  end

  def flag_message
    user = @child.histories.select { |h| h["changes"]["flag"] }.first["user_name"]
    message = (@child.flag_message.blank? && "") || ": \"#{@child.flag_message}\""
    I18n.t("child.flagged_as_suspected") + " #{user}#{message}"
  end

  def flag_summary_for_child(child)
    flag_history = child["histories"].select { |h| h["changes"].keys.include?("flag") }.first
    "<b>" + I18n.t("child.flagged_by") + " </b>" + flag_history["user_name"] + "<b> " + I18n.t("preposition.on_label") + "</b> " + current_user.localize_date(flag_history["datetime"]) + "<b> " + I18n.t("preposition.because") + "</b> " + child["flag_message"]
  end

  def reunited_message
    "Reunited"
  end

  def duplicate_message
    raw("This record has been marked as a duplicate and is no longer active. To see the Active record click #{link_to 'here', child_path(@child.duplicate_of)}.")
  end

  def field_value_for_display(field_value)
    return "" if field_value.nil? || field_value.length == 0
    return field_value.join ", " if field_value.instance_of? Array
    field_value
  end

  def link_for_filter(filter, selected_filter)
    return filter.capitalize if filter == selected_filter
    link_to(filter.capitalize, child_filter_path(filter))
  end

  def link_for_order_by(filter, order, order_id, selected_order)
    return order_id.capitalize if order == selected_order
    link_to(order_id.capitalize, child_filter_path(:filter => filter, :order_by => order))
  end

  def toolbar_for_child(child)
    if child.duplicate?
      link_to 'View the change log', child_history_path(child)
    else
      render :partial => "show_child_toolbar"
    end
  end

  def order_options_array_from(system_fields, form_sections)
    system_fields ||= []
    form_sections ||= []
    options = {}
    options[t("children.order_by.system_fields")] = system_fields.map { |f| [t("children.order_by.#{f}"), f] }
    form_sections.each do |form_section|
      options_for_form = form_section.all_sortable_fields.map { |f| [f.display_name, f.name] }
      options[form_section.name] = options_for_form
    end
    options
  end

  def child_sorted_highlighted_fields
    Form.find_by_name(Child::FORM_NAME).sorted_highlighted_fields
  end
end
