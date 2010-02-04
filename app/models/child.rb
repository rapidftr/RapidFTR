class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :isAgeExact
  property :gender
<<<<<<< HEAD

  def photo= photo_file

    if (has_attachment? :photo)
      update_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    else
      create_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    end
  end

  def photo
    fetch_attachment :photo
  end
=======
  property :origin
  property :lastKnownLocation
 # property :dateOfSeparation

>>>>>>> 4c476af9bc4f831f206554cb4a17b27f6c07d34f
end
