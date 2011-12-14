module ChildrenHelper
  def thumbnail_tag(child, key = nil)
    image_tag(child_thumbnail_path(child, key), :alt=> child['name'])
  end

  def link_to_photo_with_key(key)
    link_to thumbnail_tag(@child, key),
      child_photo_path(@child, key),
      :id => key,
      :target => '_blank'
  end

  def link_to_download_audio_with_key(key)
    link_to key.humanize, child_audio_url(@child.id,key),:id => key, :target => '_blank'
  end
  
  def is_playable_in_browser audio
    AudioMimeTypes.browser_playable? audio.mime_type
  end
  
  def link_to_update_info(child)
    link_to('and others', child_history_path(child)) unless child.has_one_interviewer?
  end

  def flag_message
    user = @child.histories.select{|h| h["changes"]["flag"]}.first["user_name"]
    message = (@child.flag_message.blank? && "") || ": \"#{@child.flag_message}\""
    "Flagged as suspect record by #{user}#{message}"
  end

  def reunited_message
    "Reunited"
  end

	def field_value_for_display field_value
		return "&nbsp;" if field_value.nil? || field_value.length==0
		return field_value.join ", " if field_value.instance_of? Array
		return field_value
  end
  
  def link_for_filter filter, selected_filter
    return filter.capitalize if filter == selected_filter
    return "<a href=\"" + child_filter_path(filter) + "\">" + filter.capitalize + "</a>"
  end
  
  def link_for_order_by filter, order, selected_order
    return order.capitalize if order == selected_order || (order == 'most recently flagged' && selected_order.nil?)
    return "<a href=\"" + child_filter_path(filter, :order_by => order) + "\">" + order.capitalize + "</a>"
  end

end