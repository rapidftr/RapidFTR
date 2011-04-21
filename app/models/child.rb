class Child < CouchRestRails::Document
  use_database :child
  require "uuidtools"
  include CouchRest::Validation
  include Searchable
  Sunspot::Adapters::DataAccessor.register(DocumentDataAccessor, Child)
  Sunspot::Adapters::InstanceAdapter.register(DocumentInstanceAccessor, Child)

  before_save :initialize_history, :if => :new?
  before_save :update_history, :unless => :new?
  property :age
  property :name
  property :nickname
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
  validates_with_method :validate_has_at_least_one_field_value
	validates_with_method :created_at, :method => :validate_created_at
  
  def self.build_solar_schema
    fields = ["unique_identifier"]  + Field.all_text_names

    Sunspot.setup(Child) do
      text *fields
    end
  end
 

  def validate_has_at_least_one_field_value
    return true if FormSection.all_enabled_child_fields.any? { |field| is_filled_in? field }
    return true if !@file_name.nil? || !@audio_file_name.nil?
    return true if deprecated_fields.any?{|key,value| !value.nil?}
    [false, "Please fill in at least one field or upload a file"]
  end
  
  def validate_file_name
    return true if @file_name == nil || /([^\s]+(\.(?i)(jpg|jpeg|png))$)/ =~ @file_name
    [false, "Please upload a valid photo file (jpg or png) for this child record"]
  end
  
  def validate_audio_file_name
    return true if @audio_file_name == nil || /([^\s]+(\.(?i)(amr|mp3))$)/ =~ @audio_file_name
    [false, "Please upload a valid audio file (amr or mp3) for this child record"]
  end

	def validate_created_at
		begin
			if self['created_at']
				DateTime.parse self['created_at'] 
			end
			true
		rescue
			[false, '']
		end
	end
  
  def method_missing(m, *args, &block)  
    self[m]
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
    
    SearchService.search [ SearchCriteria.new(:field => "name", :value => query) ]
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
    self['created_at'] ||= current_formatted_time
    self['posted_at'] = current_formatted_time
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
    return nil if self['audio_attachments'].nil?
    attachment_key = self['audio_attachments']['original']
    return nil unless has_attachment? attachment_key

    data = read_attachment attachment_key
    content_type = self['_attachments'][attachment_key]['content_type']
    FileAttachment.new attachment_key, content_type, data
  end

  def audio=(audio_file)
    return unless audio_file.respond_to? :content_type
    @audio_file_name = audio_file.original_path
    attachment = FileAttachment.from_uploadable_file(audio_file, "audio")

    attach(attachment, attachment.name)
    setup_original_audio(attachment)
    setup_mime_specific_audio(attachment)
  end

  def add_audio_file(audio_file, content_type)
    attachment = FileAttachment.from_file(audio_file, content_type, "audio", key_for_content_type(content_type))
    attach(attachment, attachment.name)
    setup_mime_specific_audio(attachment)
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
    Time.now.getutc.strftime("%Y-%m-%d %H:%M:%SUTC")
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
  
  def is_filled_in? field
    !(self[field.name].nil? || self[field.name] == field.default_value)
  end

  private
  def attach(attachment, key)
    self[key] = attachment.name
    create_attachment :name => attachment.name,
                      :content_type => attachment.content_type,
                      :file => attachment.data

  end
  
  def deprecated_fields
    system_fields = ["created_at","posted_at", "posted_from", "_rev", "_id", "created_by", "couchrest-type", "histories", "unique_identifier"]
    existing_fields = system_fields + FormSection.all_enabled_child_fields.map {|x| x.name}
    self.reject {|k,v| existing_fields.include? k} 
  end

  def setup_original_audio(attachment)
    audio_attachments = (self['audio_attachments'] ||= {})
    audio_attachments.clear
    audio_attachments['original'] = attachment.name
  end

  def setup_mime_specific_audio(file_attachment)
    audio_attachments = (self['audio_attachments'] ||= {})
    content_type_for_key = file_attachment.mime_type.to_sym.to_s
    audio_attachments[content_type_for_key] = file_attachment.name
  end

  def key_for_content_type(content_type)
    Mime::Type.lookup(content_type).to_sym.to_s
  end
  
end
