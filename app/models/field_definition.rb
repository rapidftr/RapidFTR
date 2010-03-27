class FieldDefinition < Hash
  include CouchRest::CastedModel

  property :name
  property :type
  property :options
end