class HighlightInformation
  include CouchRest::Model::CastedModel

  property :order
  property :highlighted, TrueClass, :default => false
end
