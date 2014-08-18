class ChildMediaController < ApplicationController
  helper :children
  before_action :find_child
  before_action :find_photo_attachment, :only => [:show_photo, :show_resized_photo, :show_thumbnail]

  def index
    render :json => photos_details
  end

  def show_photo
    send_photo_data(@attachment.data.read, :type => @attachment.content_type, :disposition => 'inline')
  end

  def show_resized_photo
    resized = @attachment.resize params[:size]
    send_photo_data(resized.data.read, :type => @attachment.content_type, :disposition => 'inline')
  end

  def show_thumbnail
    resized = @attachment.resize '160x160'
    send_photo_data(resized.data.read, :type => @attachment.content_type, :disposition => 'inline')
  end

  def download_audio
    find_audio_attachment
    redirect_to(:controller => 'children', :action => 'show', :id => @child.id) && return unless @attachment
    send_data(@attachment.data.read, :filename => audio_filename(@attachment), :type => @attachment.content_type)
  end

  def manage_photos
    @photos_details = photos_details
  end

  private

  def find_child
    @child = Child.get(params[:child_id])
  end

  def find_audio_attachment
    @attachment = params[:id] ? @child.media_for_key(params[:id]) : @child.audio
  rescue => e
    logger.error(e.inspect)
  end

  def find_photo_attachment
    redirect_to(:photo_id => @child.current_photo_key, :ts => @child.last_updated_at) && return if
      params[:photo_id].to_s.empty? && @child.current_photo_key.present?

    begin
      @attachment = params[:photo_id] == '_missing_' ? no_photo_attachment : @child.media_for_key(params[:photo_id])
    rescue => e
      logger.warn 'Error getting photo'
      logger.warn e.inspect
    end

    redirect_to :photo_id => '_missing_' if @attachment.nil?
  end

  def no_photo_attachment
    @@no_photo_clip ||= File.binread(File.join(Rails.root, 'app/assets/images/no_photo_clip.jpg'))
    FileAttachment.new 'no_photo', 'image/jpg', @@no_photo_clip
  end

  def audio_filename(attachment)
    'audio_' + @child.unique_identifier + AudioMimeTypes.to_file_extension(attachment.mime_type)
  end

  def photos_details
    @child['photo_keys'].map do |photo_key|
      {
        :photo_url => child_photo_url(@child, photo_key),
        :thumbnail_url => child_thumbnail_url(@child, photo_key),
        :select_primary_photo_url => child_select_primary_photo_url(@child, photo_key)
      }
    end
  end

  def send_photo_data(*args)
    expires_in 1.year, :public => true if params[:ts]
    send_data(*args)
  end
end
