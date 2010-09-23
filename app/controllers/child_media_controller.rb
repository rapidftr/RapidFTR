class ChildMediaController < ApplicationController
  before_filter :find_child
  before_filter :find_photo_attachment, :only => [:show_photo, :show_thumbnail]

  def show_photo
    send_data(@attachment.data.read, :type => @attachment.content_type, :disposition => 'inline')
  end

  def show_thumbnail
    image = MiniMagick::Image.from_blob(@attachment.data.read)
    thumbnail = image.resize "60x60"
    send_data(thumbnail.to_blob, :type => @attachment.content_type, :disposition => 'inline')
  end

  def download_audio
    find_audio_attachment
    redirect_to( :controller => 'children', :action => 'show', :id => @child.id) and return  unless @attachment
    send_data(@attachment.data.read, :file_name => "recorded_audio",:type => @attachment.content_type, :disposition => 'inline')
  end


  private
  def find_child
    @child = Child.get(params[:child_id])
  end

  def find_audio_attachment
    begin
      @attachment = params[:id] ? @child.media_for_key(params[:id]) : @child.audio
    rescue => e
    end
  end

  def find_photo_attachment
    begin
       @attachment = params[:id] ? @child.media_for_key(params[:id]) : @child.photo
    rescue => e
      p e.inspect
    end

    #TODO: there must be a better way to return a static image file
    if @attachment.nil?
      data = File.read("public/images/no_photo_clip.jpg")
      @attachment = FileAttachment.new("no_photo", "image/jpg", data)
    end
  end

end