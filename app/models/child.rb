class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :gender
end
