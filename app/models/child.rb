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

  validates_with_method :age, :method => :validate_age
  validates_with_method :validate_file_name
  validates_with_method :validate_audio_file_name
  validates_with_method :validate_custom_field_types
  validates_with_method :validate_text_field_lengths
  validates_with_method :validate_text_area_lengths
  
  def validate_custom_field_types
    fields = FormSection.all_by_order.collect{ |fs| fs[:fields] }.flatten
    fields.each do |field|
      value = (self[field[:name]].strip rescue '')
      if 'numeric_field' == field[:type]
        if value.present? and (value =~ /^\d*\.{0,1}\d+$/).nil?
          self.errors.add(field[:name], "#{field[:display_name]} must be a valid number")
        end
      end
    end
    return [self.errors.blank?, '']
  end
  
  
  def validate_text_field_lengths
      enabled_form_sections = FormSection.all_by_order.select{|form_section|form_section.enabled}
      text_fields= enabled_form_sections.collect{|form_section| form_section.all_text_fields}.flatten
      valid = true
      text_fields.each do |field|
        if (self[field.name]||"").length>200 
          self.errors = {} unless self.errors  
          self.errors.add(field.name, "#{field.display_name} cannot be more than 200 characters long") 
          valid = false
        end
      end
      return valid
  end
  def validate_text_area_lengths
      enabled_form_sections = FormSection.all_by_order.select{|form_section|form_section.enabled}
      text_fields= enabled_form_sections.collect{|form_section| form_section.all_text_areas}.flatten
      valid = true
      text_fields.each do |field|
        if (self[field.name]||"").length>400 
          self.errors = {} unless self.errors  
          self.errors.add(field.name, "#{field.display_name} cannot be more than 400 characters long") 
          valid = false
        end
      end
      return valid
  end
  
  def validate_age
    return true if age.nil? || age.blank? || (age =~ /^\d{1,2}(\.\d)?$/ && age.to_f > 0)
    [false, "Age must be between 1 and 99"]
  end
  
  def validate_file_name
    return true if @file_name == nil || /([^\s]+(\.(?i)(jpg|jpeg|png))$)/ =~ @file_name
    [false, "Please upload a valid photo file (jpg or png) for this child record"]
  end
  
  def validate_audio_file_name
    return true if @audio_file_name == nil || /([^\s]+(\.(?i)(amr))$)/ =~ @audio_file_name
    [false, "Please upload a valid audio file amr for this child record"]
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
    return nil unless attachment_name
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

  protected

  def current_formatted_time
    Time.now.strftime("%d/%m/%Y %H:%M")
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
