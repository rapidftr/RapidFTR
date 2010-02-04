class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :gender

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
end
