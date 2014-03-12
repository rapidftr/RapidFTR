class HighlightInformation < CouchRest::Model::Base
  include CouchRest::Model::CastedModel

  property :order
  property :highlighted, TrueClass, :default => false

end
