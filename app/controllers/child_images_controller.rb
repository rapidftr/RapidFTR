require 'RMagick'

class ChildImagesController < ApplicationController
  before_filter :find_child, :find_attachment

  def show_photo
    send_data(@attachment.data.read, :type => @attachment.content_type, :disposition => 'inline')
  end

  def show_thumbnail
    image = Magick::Image.from_blob(@attachment.data.read)[0]
    thumbnail = image.resize_to_fill(60)
    send_data(thumbnail.to_blob, :type => @attachment.content_type, :disposition => 'inline')
  end

  private
  def find_child
    @child = Child.get(params[:child_id])
  end

  def find_attachment
    begin
    if params[:id]
      @attachment = @child.photo_for_key params[:id]
    else
      @attachment = @child.photo
    end
    rescue => e
    end
    
    #TODO: there must be a better way to return a static image file
    if @attachment.nil?
      data = File.read("public/images/no_photo_clip.jpg")
      @attachment = FileAttachment.new("no_photo", "image/jpg", data)
    end
  end
end