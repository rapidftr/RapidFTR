module ChildrenHelper
  def thumbnail_image_tag(child)
    image_tag(child_path(child,:format => 'jpg'),:size=>"60x60", :alt=> child['name'])
  end
end
