class Child < CouchRestRails::Document
  use_database :child
  require "uuidtools"
  include CouchRest::Validation

  before_save :initialize_history, :if => :new?
  before_save :update_history, :unless => :new?
  
  def self.new_with_user_name(user_name, fields = {})
    child = new(fields)
    child.create_unique_id user_name
    child.set_creation_fields_for user_name
    child
  end
  
  def create_unique_id(user_name)
    unknown_location = 'xxx'
    truncated_location = self['last_known_location'].blank? ? unknown_location : self['last_known_location'].slice(0,3).downcase
    self['unique_identifier'] = user_name + truncated_location + UUIDTools::UUID.random_create.to_s.slice(0,5)
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

#  view_by:user_name,
#  :map => "function(doc,user_name) {
#              if ((doc['couchrest-type'] == 'child') && doc['unique_identifier'].substr(0,)
#             {
#                emit(doc['user_name'],doc);
#             }
#          }"

#  def find_by_created_user(user_name)
#    @children = Child.by_user_name(:key => user_name.downcase)
#      user_name = get_user_name_from_unique_identifier(child)
#    end
#  end

#
#  def self.get_user_name_from_unique_identifier(child)
#    user_name = child.unique_identifier.
#  end

  def photo=(photo_file)
    return unless photo_file.respond_to? :content_type
    @file_name = photo_file.original_path    
    self['current_photo_key'] = "photo-#{Time.now.strftime('%d-%m-%Y-%H%M')}"
    create_attachment :name => self['current_photo_key'], 
                      :content_type => photo_file.content_type, 
                      :file => photo_file
  end

  def photo
    read_attachment self['current_photo_key']
  end
  
  def photo_for_key(photo_key)
    read_attachment photo_key
  end
  
  def valid?(context=:default)
    valid = true
    
    if @file_name && !/([^\s]+(\.(?i)(jpg|png|gif|bmp))$)/.match(@file_name)
      valid = false
      errors.add("photo", "Please upload a valid photo file (jpg or png) for this child record")
    end
    
    if self["last_known_location"].blank?
      valid = false
      errors.add("last_known_location", "Last known location cannot be empty")
    end
    
    return valid
  end
  
  def update_properties_with_user_name(user_name, new_photo, properties)
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
    end
    self.set_updated_fields_for user_name
    self.photo = new_photo
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
    Templates.all_child_field_names.select { |field_name| changed?(field_name) }
  end
  
  def changed?(field_name)
    return false if self[field_name].blank? && @from_child[field_name].blank?
    return true if @from_child[field_name].blank?
    self[field_name].strip != @from_child[field_name].strip
  end
end
