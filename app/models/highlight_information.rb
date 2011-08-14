class HighlightInformation < Hash
  include CouchRest::CastedModel

  property :order
  property :highlighted, :cast_as => :boolean, :default => false
  
end
