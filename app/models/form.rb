class Form < CouchRest::Model::Base
  include RapidFTR::Model
  use_database :form

  property :name

  design do
    view :by_name
  end
end