module HistoriesHelper
  def link_to_photo_with_key(key)
    link_to "photo", 
      child_attachment_path(:child_id => @child.id, :id => key), 
      :id => key,
      :target => '_blank'
  end
end