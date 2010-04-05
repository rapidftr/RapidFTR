class FormSectionDefinition < CouchRestRails::Document
  use_database :form_section_definition

  property :unique_id
  property :name
  property :description
  property :enabled, :cast_as => 'boolean'
  property :order
  property :fields, :cast_as => ['FieldDefinition']

end
