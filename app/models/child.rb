class Child < CouchRestRails::Document
  use_database :child
  require "uuidtools"
  include CouchRest::Validation
  include Searchable

  Sunspot::Adapters::DataAccessor.register(DocumentDataAccessor, Child)
  Sunspot::Adapters::InstanceAdapter.register(DocumentInstanceAccessor, Child)

  Sunspot.setup(self) do
    text :name, :unique_identifier
  end

  before_save :initialize_history, :if => :new?
  before_save :update_history, :unless => :new?
  property :age
  property :name
  property :unique_identifier
  
  view_by :name,
          :map => "function(doc) {
              if (doc['couchrest-type'] == 'Child')
             {
                emit(doc['name'], doc);
             }
          }"

  validates_with_method :validate_file_name
  validates_with_method :validate_audio_file_name
  validates_fields_of_type Field::NUMERIC_FIELD
  validates_fields_of_type Field::TEXT_FIELD
  validates_fields_of_type Field::TEXT_AREA
  validates_fields_of_type Field::DATE_FIELD
  validates_with_method :age, :method => :validate_age
    
  def validate_age
    return true if age.nil? || age.blank? || !age.is_number? || (age =~ /^\d{1,2}(\.\d)?$/ && age.to_f > 0 && age.to_f < 100)
    [false, "Age must be between 1 and 99"]
  end
  
  def validate_file_name
    return true if @file_name == nil || /([^\s]+(\.(?i)(jpg|jpeg|png))$)/ =~ @file_name
    [false, "Please upload a valid photo file (jpg or png) for this child record"]
  end
  
  def validate_audio_file_name
    return true if @audio_file_name == nil || /([^\s]+(\.(?i)(amr|mp3))$)/ =~ @audio_file_name
    [false, "Please upload a valid audio file (amr or mp3) for this child record"]
  end
  
  def to_s
    if self['name'].present?
      "#{self['name']} (#{self['unique_identifier']})"
    else
      self['unique_identifier']
    end
  end

  def self.all
    view('by_name', {})
  end
  
  def self.search(search)
    return [] unless search.valid?
    
    query = search.query
    children = sunspot_search("unique_identifier_text:#{query}")
    return children if children.length > 0

    lucene_query = query.split(/[ ,]+/).map {|word| "(name_text:#{word.downcase}~ OR name_text:#{word.downcase}*)"}.join(" AND ")
    sunspot_search lucene_query
  end

  def self.new_with_user_name(user_name, fields = {})
    child = new(fields)
    child.create_unique_id user_name
    child.set_creation_fields_for user_name
    child
  end

  def create_unique_id(user_name)
    unknown_location = 'xxx'
    truncated_location = self['last_known_location'].blank? ? unknown_location : self['last_known_location'].slice(0, 3).downcase
    self['unique_identifier'] = user_name + truncated_location + UUIDTools::UUID.random_create.to_s.slice(0, 5)
  end

  def set_creation_fields_for(user_name)
    self['created_by'] = user_name
    self['created_at'] = current_formatted_time
  end

  def set_updated_fields_for(user_name)
    self['last_updated_by'] = user_name
    self['last_updated_at'] = current_formatted_time
  end

  def unique_identifier
    self['unique_identifier']
  end

  def rotate_photo(angle)
    exisiting_photo = photo
    image = MiniMagick::Image.from_blob(exisiting_photo.data.read)
    image.rotate(angle)

    name = FileAttachment.generate_name
    attachment = FileAttachment.new(name, exisiting_photo.content_type, image.to_blob)
    attach(attachment, 'current_photo_key')
  end

  def photo=(photo_file)
    return unless photo_file.respond_to? :content_type
    @file_name = photo_file.original_path
    attachment = FileAttachment.from_uploadable_file(photo_file, "photo")
    attach(attachment, 'current_photo_key')
  end

  def photo
    attachment_name = self['current_photo_key']
    return if attachment_name.blank?
    data = read_attachment attachment_name
    content_type = self['_attachments'][attachment_name]['content_type']
    FileAttachment.new attachment_name, content_type, data
  end

  def audio
    attachment_name = self['recorded_audio']
    return nil unless attachment_name && (has_attachment? attachment_name)
    data = read_attachment attachment_name
    content_type = self['_attachments'][attachment_name]['content_type']
    FileAttachment.new attachment_name, content_type, data
  end

  def audio=(audio_file)
    return unless audio_file.respond_to? :content_type
    @audio_file_name = audio_file.original_path
    attachment = FileAttachment.from_uploadable_file(audio_file, "audio")
    attach(attachment, 'recorded_audio')
  end

  def media_for_key(media_key)
    data = read_attachment media_key
    content_type = self['_attachments'][media_key]['content_type']
    FileAttachment.new media_key, content_type, data
  end

  def update_properties_with_user_name(user_name,new_photo, new_audio, properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
    self.set_updated_fields_for user_name
    self.photo = new_photo
    self.audio = new_audio
  end

  def initialize_history
    self['histories'] = []
  end

  def update_history
    if field_name_changes.any?
      self['histories'].unshift({
              'user_name' => self['last_updated_by'],
              'datetime' => self['last_updated_at'],
              'changes' => changes_for(field_name_changes) })
    end
  end
  
  def has_one_interviewer?
    user_names_after_deletion = self['histories'].map { |change| change['user_name'] }
    user_names_after_deletion.delete(self['created_by'])
    self['last_updated_by'].blank? || user_names_after_deletion.blank?
  end

  protected

  def current_formatted_time
    Time.now.getutc.strftime("%Y-%m-%d %H:%M:%S%Z")
  end

  def changes_for(field_names)
    field_names.inject({}) do |changes, field_name|
      changes.merge(field_name => {
              'from' => @from_child[field_name],
              'to' => self[field_name] })
    end
  end

  def field_name_changes
    @from_child ||= Child.get(self.id)
    FormSection.all_child_field_names.select { |field_name| changed?(field_name) }
  end

  def changed?(field_name)
    return false if self[field_name].blank? && @from_child[field_name].blank?
    return true if @from_child[field_name].blank?
    self[field_name].strip != @from_child[field_name].strip
  end

  private
  def attach(attachment, key)
    self[key] = attachment.name
    create_attachment :name => attachment.name,
                      :content_type => attachment.content_type,
                      :file => attachment.data

  end
end
