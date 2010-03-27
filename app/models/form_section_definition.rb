class FormSectionDefinition < CouchRestRails::Document
  use_database :form_section_definition

  property :name
  property :fields, :cast_as => ['FieldDefinition']
end