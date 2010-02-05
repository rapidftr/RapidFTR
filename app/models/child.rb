class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :isAgeExact
  property :origin
  property :lastKnownLocation
  # property :dateOfSeparation
  property :gender

  def photo= photo_file
    return unless photo_file.is_a? File
    if (has_attachment? :photo)
      update_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    else
      create_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    end
  end

  def photo
    read_attachment "photo"
  end
end
