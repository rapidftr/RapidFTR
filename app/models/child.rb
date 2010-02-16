class Child < CouchRestRails::Document
  use_database :child
  include CouchRest::Validation

  property :name
  property :age
  property :isAgeExact
  property :gender
  property :origin
  property :lastKnownLocation
  DATE_OF_SEPARATION= [' ', '1-2 weeks ago','2-4 weeks ago','1-6 months ago','6 months to 1 year ago','More than 1 year ago']
  property :DATE_OF_SEPARATION

  validates_presence_of :lastKnownLocation,:message=>"Last known location cannot be empty"

  def photo= photo_file
    return unless photo_file.respond_to? :content_type
    @file_name = photo_file.original_path
    if (has_attachment? :photo)
      update_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    else
      create_attachment(:name => "photo", :content_type => photo_file.content_type, :file => photo_file)
    end
  end

  def photo
    read_attachment "photo"
  end

  def valid?  context=:default
    all_others_are_valid = super context

    photo_is_valid = true

    if (!/([^\s]+(\.(?i)(jpg|png|gif|bmp))$)/.match(@file_name))
      photo_is_valid = false
      errors.add("photo", "Please upload a valid photo file (jpg or png) for this child record")
    end

    return all_others_are_valid && photo_is_valid
  end

end
