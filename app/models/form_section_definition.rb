class FormSectionDefinition < CouchRestRails::Document
  use_database :form_section_definition

  property :unique_id
  property :name
  property :description
  property :enabled, :cast_as => 'boolean'
  property :order
  property :fields, :cast_as => ['FieldDefinition']

  view_by :unique_id

  def self.get_by_unique_id unique_id
    by_unique_id(:key => unique_id).first
  end
  def self.add_field_to_formsection formsection, field
    raise "Field already exists for this formsection" if formsection.has_field(field.name)
    formsection.fields.push(field)
    formsection.save
  end

  def has_field field_name
    fields.find {|field| field.name == field_name} != nil
  end
end
