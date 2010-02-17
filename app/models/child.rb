class Child < CouchRestRails::Document
  use_database :child
  include CouchRest::Validation

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
    valid = true

    if (!/([^\s]+(\.(?i)(jpg|png|gif|bmp))$)/.match(@file_name))
      valid = false
      errors.add("photo", "Please upload a valid photo file (jpg or png) for this child record")
    end

    last_known_location = self["basic_details"]["last_known_location"]

    if last_known_location.blank?
      valid = false
      errors.add("last_known_location", "Last known location cannot be empty")
    end


    return valid
  end

end
