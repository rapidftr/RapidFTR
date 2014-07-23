class Form < CouchRest::Model::Base
  include RapidFTR::Model
  use_database :form

  collection_of :form_sections

  property :name

  design do
    view :by_name
  end
end