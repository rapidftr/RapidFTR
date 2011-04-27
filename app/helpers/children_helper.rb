module ChildrenHelper
  def thumbnail_tag(child, id)
    return image_tag(no_photo_available_thumbnail_path, :alt => "No photo available")  if id.nil?
    image_tag(child_thumbnail_path(child, id), :alt => child['name'])
  end

  def link_to_photo_with_id(id)
    link_to thumbnail_tag(@child, id),
      child_photo_path(@child, id),
      :id => id,
      :target => '_blank'
  end

  def no_photo_available_path
    "/images/no_photo_clip.jpg"
  end

  def no_photo_available_thumbnail_path
    "/images/no_photo_available_thumb.jpg"
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
  
end
