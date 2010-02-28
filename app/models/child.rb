class Child < CouchRestRails::Document
  use_database :child
  require "uuidtools"
  include CouchRest::Validation

  before_save :initialize_history, :if => :new_record?
  before_save :update_history, :unless => :new_record?
  
  def self.new_with_user_name(user_name, fields)
    child = new(fields)
    child.create_unique_id user_name
    child['created_by'] = user_name
    child['created_at'] = Time.now.strftime("%m/%d/%y %H:%M")
    child
  end
  
  def create_unique_id(user_name)
    unknown_location = 'xxx'
    truncated_location = self['last_known_location'].blank? ? unknown_location : self['last_known_location'].slice(0,3).downcase
    self['unique_identifier'] = user_name + truncated_location + UUIDTools::UUID.random_create.to_s.slice(0,5)
  end

  def photo=(photo_file)
    return unless photo_file.respond_to? :content_type
    @file_name = photo_file.original_path
    if (has_attachment? :photo)
      update_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    else
      create_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    end
  end

  def photo
    read_attachment "photo"
  end

  def valid?(context=:default)
    valid = true
    
    if (new? && !/([^\s]+(\.(?i)(jpg|png|gif|bmp))$)/.match(@file_name))
      valid = false
      errors.add("photo", "Please upload a valid photo file (jpg or png) for this child record")
    end

    if self["last_known_location"].blank?
      valid = false
      errors.add("last_known_location", "Last known location cannot be empty")
    end


    return valid
  end

  def update_properties_from(child, user_name)
    child.each_pair do |name, value|
      self[name] = value unless value == nil
    end
    self['last_updated_by'] = user_name
    self['last_updated_at'] = Time.now.strftime("%m/%d/%y %H:%M")
  end
  
  def initialize_history
    self['histories'] = []
  end

  def update_history
    if field_name_changes.any?
      self['histories'] << { 
        'user_name' => self['last_updated_by'],
        'datetime' => self['last_updated_at'],
        'changes' => changes_for(field_name_changes) }
    end
  end
  
  protected
  
  def changes_for(field_names)
    field_names.inject({}) do |changes, field_name|
      changes.merge(field_name => { 
        'from' => @from_child[field_name], 
        'to' => self[field_name] })
    end
  end
  
  def field_name_changes
    @from_child = Child.get(self.id)
    field_names = Templates.get_template.map { |field| field['name'] }
    field_names.select { |field_name| self[field_name] != @from_child[field_name] }
  end  
end
