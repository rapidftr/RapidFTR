class Child < CouchRestRails::Document
  use_database :child

  property :name
  property :age
  property :isAgeExact
  property :gender
  property :origin
  property :lastKnownLocation
  DATE_OF_SEPARATION= [' ', '1-2 weeks ago','2-4 weeks ago','1-6 months ago','6 months to 1 year ago','More than 1 year ago']
  property :DATE_OF_SEPARATION
  

  def photo= photo_file
    return unless photo_file.respond_to? :content_type
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
