module ChildBuilder

  def given_a_child
    @child = double(:child)
    self
  end

  def with_id(child_id)
    Child.stub(:get).with(child_id).and_return @child
    Child.stub(:all).and_return [@child]
    @child.stub(:id).and_return child_id
    @child.stub(:last_updated_at).and_return(Date.today)
    self
  end

  def with_unique_identifier(identifier)
    @child.stub(:unique_identifier).and_return identifier
    self
  end

  def with_photo(image, image_id = "img", current = true)
    photo = FileAttachment.new image_id, image.content_type, image.data

    @child.stub(:media_for_key).with(image_id).and_return photo
    @child.stub(:current_photo_key).and_return(image_id) if current
    @child.stub(:primary_photo).and_return photo if current
    self
  end

  def with_audio(audio, audio_id ="audio", current = true)
    audio = double(FileAttachment, {:content_type => audio.content_type, :mime_type => audio.mime_type, :data => StringIO.new(audio.data) })
    @child.stub(:media_for_key).with(audio_id).and_return audio
    @child.stub(:audio).and_return audio if current
  end

  def with_no_photos
    @child.stub(:current_photo_key).and_return nil
    @child.stub(:media_for_key).and_return nil
    @child.stub(:primary_photo).and_return nil
    self
  end

  def with_rev(revision)
    @child.stub(:rev).and_return revision
    self
  end

  def with(hash)
    hash.each do |(key, value)|
      @child.stub(key).and_return(value)
    end
    self
  end

end
