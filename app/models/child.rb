class Child < CouchRestRails::Document
  use_database :child
  require "uuidtools"
  include CouchRest::Validation
  include RapidFTR::Model
  include Searchable
  Sunspot::Adapters::DataAccessor.register(DocumentDataAccessor, Child)
  Sunspot::Adapters::InstanceAdapter.register(DocumentInstanceAccessor, Child)

  before_save :update_history, :unless => :new?
  before_save :update_photo_keys

  property :age
  property :name
  property :nickname
  property :unique_identifier
  property :flag, :cast_as => :boolean
  property :reunited, :cast_as => :boolean
  property :investigated, :cast_as => :boolean
  property :duplicate, :cast_as => :boolean

  view_by :name,
          :map => "function(doc) {
              if (doc['couchrest-type'] == 'Child')
             {
                if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                  emit(doc['name'], doc);
                }
             }
          }"

  view_by :flag,
          :map => "function(doc) {
                if (doc.hasOwnProperty('flag'))
               {
                 if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                   emit(doc['flag'],doc);
                 }
               }
            }"

  view_by :unique_identifier,
          :map => "function(doc) {
                if (doc.hasOwnProperty('unique_identifier'))
               {
                  emit(doc['unique_identifier'],doc);
               }
            }"

  view_by :duplicate,
          :map => "function(doc) {
            if (doc.hasOwnProperty('duplicate')) {
              emit(doc['duplicate'], doc);
            }
          }"

view_by :duplicates_of,
          :map => "function(doc) {
            if (doc.hasOwnProperty('duplicate_of')) {
              emit(doc['duplicate_of'], doc);
            }
          }"

  view_by :flag,
          :map => "function(doc) {
                if (doc.hasOwnProperty('flag'))
               {
                  emit(doc['flag'],doc);
               }
            }"

  view_by :created_by

  validates_with_method :validate_photos
  validates_with_method :validate_photos_size
  validates_with_method :validate_audio_file_name
  validates_with_method :validate_audio_size
  validates_fields_of_type Field::NUMERIC_FIELD
  validates_fields_of_type Field::TEXT_FIELD
  validates_fields_of_type Field::TEXT_AREA
  validates_fields_of_type Field::DATE_FIELD
  validates_with_method :validate_has_at_least_one_field_value
  validates_with_method :created_at, :method => :validate_created_at
  validates_with_method :last_updated_at, :method => :validate_last_updated_at

  def initialize *args
    self['photo_keys'] ||= []
    self['current_photo_key'] = nil
    self['histories'] = []
    super *args
  end

  def field_definitions
    @field_definitions ||= FormSection.all_enabled_child_fields
  end

  def self.build_solar_schema
    text_fields = build_text_fields_for_solar
    date_fields = build_date_fields_for_solar
    Sunspot.setup(Child) do
      text *text_fields
      date *date_fields
      date_fields.each { |date_field| date date_field }
      boolean :duplicate
    end
  end

  def self.build_text_fields_for_solar
    ["unique_identifier", "created_by", "created_by_full_name", "last_updated_by", "last_updated_by_full_name"] +  Field.all_text_names
  end

  def self.build_date_fields_for_solar
    ["created_at", "last_updated_at"]
  end

  def validate_has_at_least_one_field_value
    return true if field_definitions.any? { |field| is_filled_in? field }
    return true if !@file_name.nil? || !@audio_file_name.nil?
    return true if deprecated_fields.any?{|key,value| !value.nil? && value != [] }
    [false, "Please fill in at least one field or upload a file"]
  end

  def validate_age
    return true if age.nil? || age.blank? || !age.is_number? || (age =~ /^\d{1,2}(\.\d)?$/ && age.to_f > 0 && age.to_f < 100)
    [false, "Age must be between 1 and 99"]
  end

  def validate_photos
    return true if @photos.blank? || @photos.all?{|photo| /image\/(jpg|jpeg|png)/ =~ photo.content_type }
    [false, "Please upload a valid photo file (jpg or png) for this child record"]
  end

  def validate_photos_size
    return true if @photos.blank? || @photos.all?{|photo| photo.size < 10.megabytes }
    [false, "File is too large"]
  end

  def validate_audio_size
    return true if @audio.blank? || @audio.size < 10.megabytes
    [false, "File is too large"]
  end

  def validate_audio_file_name
    return true if @audio_file_name == nil || /([^\s]+(\.(?i)(amr|mp3))$)/ =~ @audio_file_name
    [false, "Please upload a valid audio file (amr or mp3) for this child record"]
  end

  def has_valid_audio?
    validate_audio_size.is_a?(TrueClass) && validate_audio_file_name.is_a?(TrueClass)
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

  def validate_last_updated_at
 		begin
 			if self['last_updated_at']
 				DateTime.parse self['last_updated_at']
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

  def self.all_by_creator(created_by)
    self.by_created_by :key => created_by
  end

  # this is a helper to see the duplicates for test purposes ... needs some more thought. - cg
  def self.duplicates
    by_duplicate(:key => true)
  end

  def self.duplicates_of(id)
    duplicates = by_duplicates_of(:key => id)
    duplicates ||= Array.new
    duplicates
  end

  def self.search_by_created_user(search, created_by)
    created_by_criteria = [SearchCriteria.new(:field => "created_by", :value => created_by, :join => "AND")]
    search(search, created_by_criteria, created_by)
  end

  def self.search(search, criteria = [], created_by = "")
    return [] unless search.valid?

    query = search.query
    solr_query = "unique_identifier_text:#{query}"
    solr_query = solr_query + "AND created_by_text:#{created_by}" unless created_by.empty?
    children = sunspot_search(solr_query)
    return children if children.length > 0

    search_criteria = [SearchCriteria.new(:field => "name", :value => search.query)].concat(criteria)
    SearchService.search search_criteria
  end

  def self.flagged
    by_flag(:key => 'true')
  end

  def self.new_with_user_name(user_name, fields = {})
    child = new(fields)
    child.create_unique_id user_name unless child['unique_identifier']
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

  def last_updated_by
    self['last_updated_by'] || self['created_by']
  end

  def last_updated_at
    self['last_updated_at'] || self['created_at']
  end

  def unique_identifier
    self['unique_identifier']
  end

  def rotate_photo(angle)
    existing_photo = primary_photo
    image = MiniMagick::Image.from_blob(existing_photo.data.read)
    image.rotate(angle)

    attachment = FileAttachment.new(existing_photo.name, existing_photo.content_type, image.to_blob)

    photo_key_index = self['photo_keys'].find_index(existing_photo.name)
    self['photo_keys'].delete_at(photo_key_index)
    delete_attachment(existing_photo.name)
    self['photo_keys'].insert(photo_key_index, existing_photo.name)
    attach(attachment)
  end

  def delete_photo(delete_photo)
    delete_photos([delete_photo])
  end

  def delete_photos(delete_photos)
    return unless delete_photos
    if delete_photos.is_a? Hash
          delete_photos = delete_photos.keys
        end
    @deleted_photo_keys ||= []
    @deleted_photo_keys.concat(delete_photos)
  end

  def photo=(new_photos)
    return unless new_photos
    #basically to support any client passing a single photo param, only used by child_spec AFAIK
    if new_photos.is_a? Hash
      photos = new_photos.to_a.sort.map {|k, v| v }
    else
      photos = [new_photos]
    end
    self.photos = photos
  end

  def photos=(new_photos)
    @photos = []
    @new_photo_keys = new_photos.select {|photo| photo.respond_to? :content_type}.collect do |photo|
      @photos <<  photo
      attachment = FileAttachment.from_uploadable_file(photo, "photo-#{photo.path.hash}")
      attach(attachment)
      attachment.name
    end
  end

  def update_photo_keys
    return if @new_photo_keys.blank? && @deleted_photo_keys.blank?

    self['photo_keys'].concat(@new_photo_keys).uniq! if @new_photo_keys

    @deleted_photo_keys.each { |p| self['photo_keys'].delete(p) } if @deleted_photo_keys

    self['current_photo_key'] = self['photo_keys'].first unless self['photo_keys'].include?(self['current_photo_key'])

    add_to_history(photo_changes_for(@new_photo_keys, @deleted_photo_keys)) unless id.nil?

    @new_photo_keys, @deleted_photo_keys = nil, nil
  end

  def photos
    return [] if self['photo_keys'].blank?
    self['photo_keys'].collect do |key|
      attachment(key)
    end
  end

  def photos_index
    return [] if self['photo_keys'].blank?
    self['photo_keys'].collect do |key|
      {
        :photo_uri => child_photo_url(self, key),
        :thumbnail_uri => child_photo_url(self, key)
      }
    end
  end

  def primary_photo
    key = self['current_photo_key']
    key ? attachment(key) : nil
  end

  def primary_photo_id
    self['current_photo_key']
  end

  def primary_photo_id=(photo_key)
    unless self['photo_keys'].include?(photo_key)
      raise "Failed trying to set '#{photo_key}' to primary photo: no such photo key"
    end
    self['current_photo_key'] = photo_key
  end

  def audio
    return nil if self.id.nil? || self['audio_attachments'].nil?
    attachment_key = self['audio_attachments']['original']
    return nil unless has_attachment? attachment_key

    data = read_attachment attachment_key
    content_type = self['_attachments'][attachment_key]['content_type']
    FileAttachment.new attachment_key, content_type, data
  end

  def audio=(audio_file)
    return unless audio_file.respond_to? :content_type
    @audio_file_name = audio_file.original_filename
    @audio = audio_file
    attachment = FileAttachment.from_uploadable_file(audio_file, "audio")
    self['recorded_audio'] = attachment.name
    attach(attachment)
    setup_original_audio(attachment)
    setup_mime_specific_audio(attachment)
  end

  def add_audio_file(audio_file, content_type)
    attachment = FileAttachment.from_file(audio_file, content_type, "audio", key_for_content_type(content_type))
    attach(attachment)
    setup_mime_specific_audio(attachment)
  end

  def media_for_key(media_key)
    data = read_attachment media_key
    content_type = self['_attachments'][media_key]['content_type']
    FileAttachment.new media_key, content_type, data
  end

  def update_properties_with_user_name(user_name, new_photo, delete_photos, new_audio, properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
    self.set_updated_fields_for user_name
    self.delete_photos(delete_photos)
    self.photo = new_photo
    self.audio = new_audio
  end

  def update_history
    if field_name_changes.any?
      add_to_history(changes_for(field_name_changes))
    end
  end

  def has_one_interviewer?
    user_names_after_deletion = self['histories'].map { |change| change['user_name'] }
    user_names_after_deletion.delete(self['created_by'])
    self['last_updated_by'].blank? || user_names_after_deletion.blank?
  end

  def mark_as_duplicate(parent_id)
    self['duplicate'] = true
    self['duplicate_of'] = Child.by_unique_identifier(:key => parent_id).first.id
  end

  protected

  def add_to_history(changes)
      self['histories'].unshift({
              'user_name' => last_updated_by,
              'datetime' => last_updated_at,
              'changes' => changes })
  end

  def current_formatted_time
    Clock.now.getutc.strftime("%Y-%m-%d %H:%M:%SUTC")
  end

  def changes_for(field_names)
    field_names.inject({}) do |changes, field_name|
      changes.merge(field_name => {
        'from' => @from_child[field_name],
        'to' => self[field_name]
      })
    end
  end

  def photo_changes_for(new_photo_keys, deleted_photo_keys)
    return if new_photo_keys.blank? && deleted_photo_keys.blank?
    { 'photo_keys' => { 'added' => new_photo_keys, 'deleted' => deleted_photo_keys } }
  end

  def field_name_changes
    @from_child ||= Child.get(self.id)
		field_names = field_definitions.map {|f| f.name}
    other_fields = [
      "flag", "flag_message",
      "reunited", "reunited_message",
      "investigated", "investigated_message",
      "duplicate", "duplicate_of"
    ]
		all_fields = field_names + other_fields
		all_fields.select { |field_name| changed?(field_name) }
  end

  def changed?(field_name)
    return false if self[field_name].blank? && @from_child[field_name].blank?
    return true if @from_child[field_name].blank?
    if self[field_name].respond_to? :strip
       self[field_name].strip != @from_child[field_name].strip
    else
       self[field_name] != @from_child[field_name]
    end
  end

  def is_filled_in? field
    !(self[field.name].nil? || self[field.name] == field.default_value)
  end

  private
  def attachment(key)
    data = read_attachment key
    content_type = self['_attachments'][key]['content_type']
    FileAttachment.new key, content_type, data
  end

  def attach(attachment)
    create_attachment :name => attachment.name,
                      :content_type => attachment.content_type,
                      :file => attachment.data
  end

  def deprecated_fields
    system_fields = ["created_at",
                     "last_updated_at",
                     "last_updated_by",
                     "last_updated_by_full_name",
                     "posted_at",
                     "posted_from",
                     "_rev",
                     "_id",
                     "created_by",
                     "created_by_full_name",
                     "couchrest-type",
                     "histories",
                     "unique_identifier",
                     "current_photo_key",
                     "photo_keys"]
    existing_fields = system_fields + field_definitions.map {|x| x.name}
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
