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
end
