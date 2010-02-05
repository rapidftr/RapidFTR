class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :isAgeExact
  property :gender
  property :origin
  property :lastKnownLocation
 # property :dateOfSeparation

end
