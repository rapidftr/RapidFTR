class MediaController < ApplicationController
  NO_PHOTO_FORMAT = 'jpg'
  NO_PHOTO_CLIP = File.binread(Rails.root.join("app/assets/images/no_photo_clip.#{NO_PHOTO_FORMAT}"))
  before_action :find_model
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
    controller = controller_name_from_current_uri
    redirect_to(:controller => controller, :action => 'show', :id => @model.id) && return unless @attachment
    send_data(@attachment.data.read, :filename => audio_filename(@attachment), :type => @attachment.content_type)
  end

  def manage_photos
    @photos_details = photos_details
  end

  private

  def find_model
    model_class = model_name_from_current_uri
    model_id = "#{model_class}_id".downcase.to_sym
    @model = model_class.get(params[model_id])
  end

  def find_audio_attachment
    @attachment = params[:id] ? @model.media_for_key(params[:id]) : @model.audio
  rescue => e
    logger.error(e.inspect)
  end

  def find_photo_attachment
    redirect_to(:photo_id => @model.current_photo_key, :ts => @model.last_updated_at) && return if
      params[:photo_id].to_s.empty? && @model.current_photo_key.present?

    begin
      @attachment = params[:photo_id] == '_missing_' ? no_photo_attachment : @model.media_for_key(params[:photo_id])
    rescue => e
      logger.warn 'Error getting photo'
      logger.warn e.inspect
    end

    redirect_to :photo_id => '_missing_' if @attachment.nil?
  end

  def no_photo_attachment
    FileAttachment.new('no_photo', "image/#{NO_PHOTO_FORMAT}", NO_PHOTO_CLIP)
  end

  def audio_filename(attachment)
    'audio_' + @model.unique_identifier + AudioMimeTypes.to_file_extension(attachment.mime_type)
  end

  def photos_details
    @model['photo_keys'].map do |photo_key|
      {
        :photo_url => child_photo_url(@model, photo_key),
        :thumbnail_url => child_thumbnail_url(@model, photo_key),
        :select_primary_photo_url => child_select_primary_photo_url(@model, photo_key)
      }
    end
  end

  def send_photo_data(*args)
    expires_in 1.year, :public => true if params[:ts]
    send_data(*args)
  end

  def model_name_from_current_uri
    url_for(:only_path => true).split('/')[1].singularize.capitalize.constantize
  end

  def controller_name_from_current_uri
    model_name = model_name_from_current_uri.to_s
    model_name.downcase.pluralize
  end
end
