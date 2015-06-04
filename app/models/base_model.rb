class BaseModel < CouchRest::Model::Base
  include PhotoHelper
  include AudioHelper
  include AttachmentHelper
  include RecordHelper
  include RapidFTR::CouchRestRailsBackward

  validate :validate_photos_size
  validate :validate_photos
  validate :validate_audio_size
  validate :validate_audio_file_name

  before_save :update_organisation
  before_save :update_photo_keys
  before_save :update_history, :unless => :new?
  before_save :add_creation_history, :if => :new?
  before_save :add_last_updated_at, :if => :new?

  def initialize(*args)
    self['photo_keys'] ||= []
    arguments = args.first

    if arguments.is_a?(Hash) && arguments['current_photo_key']
      self['current_photo_key'] = arguments['current_photo_key']
      arguments.delete('current_photo_key')
    end

    self['histories'] = []
    super(*args)
  end

  def self.new_with_user_name(user, fields = {})
    model = new(fields)
    model.creation_fields_for(user)
    model
  end

  def self.without_histories
    skip_callback(:save, :before, :update_history)
    skip_callback(:save, :before, :add_creation_history)
    yield if block_given?
  ensure
    set_callback(:save, :before, :update_history, :unless => :new?)
    set_callback(:save, :before, :add_creation_history, :if => :new?)
  end

  def method_missing(method, *)
    self[method]
  end

  def validate_photos
    return true if @photos.blank? || @photos.all? { |photo| /image\/(jpg|jpeg|png)/ =~ photo.content_type }
    errors.add(:photo, I18n.t('errors.models.child.photo_format'))
  end

  def validate_photos_size
    return true if @photos.blank? || @photos.all? { |photo| photo.size < 10.megabytes }
    errors.add(:photo, I18n.t('errors.models.child.photo_size'))
  end

  def validate_audio_size
    return true if @audio.blank? || @audio.size < 10.megabytes
    errors.add(:audio, I18n.t('errors.models.child.audio_size'))
  end

  def validate_audio_file_name
    return true if @audio_file_name.nil? || /([^\s]+(\.(?i)(amr|mp3))$)/ =~ @audio_file_name
    errors.add(:audio, 'Please upload a valid audio file (amr or mp3) for this child record')
  end

  def key_for_content_type(content_type)
    Mime::Type.lookup(content_type).to_sym.to_s
  end

  def has_valid_audio?
    validate_audio_size.is_a?(TrueClass) && validate_audio_file_name.is_a?(TrueClass)
  end

  def create_unique_id
    self.unique_identifier ||= UUIDTools::UUID.random_create.to_s
    self.short_id = unique_identifier.last 7
  end

  def add_last_updated_at
    self[:last_updated_at] = self.created_at
  end
end
