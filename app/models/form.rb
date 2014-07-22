class Form < CouchRest::Model::Base
  include RapidFTR::Model
  use_database :form

  property :name

  design do
  end
end