class SuggestedField   < CouchRestRails::Document
  use_database :suggested_field

  property :unique_id
  property :name
  property :description
  property :field, :cast_as => 'FieldDefinition'
  property :is_used, :cast_as => 'boolean'

  view_by :is_used
  # Should unique_id just be the unique id for the record??
  view_by :unique_id

  def self.mark_as_used suggested_field_id
    suggested_field = get_by_unique_id suggested_field_id
    suggested_field.is_used = true
    suggested_field.save
  end
  def self.get_by_unique_id unique_id
    self.by_unique_id(:key=>unique_id).first
  end
  def self.all_unused 
    return self.by_is_used :key=>false
  end
end