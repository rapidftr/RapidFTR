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
    media_type = Media::Type.lookup(audio.content_type.downcase)
    AudioMediaTypes.browser_playable? media_type
  end
end
