class HighlightInformation
  include CouchRest::Model::Embeddable

  property :order, :default => "0"
  property :highlighted, TrueClass, :default => false

end
