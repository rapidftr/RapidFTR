class Role < CouchRestRails::Document
  use_database :role

  include CouchRest::Validation
  include RapidFTR::Model

  property :name
  property :description
  property :permissions, :type => [String]

  validates_presence_of :name
  validates_presence_of :permissions, :message => "Please select at least one permission"

end

