module ChildBuilder
  def given_a_child
    @child = double(:child)
    self
  end

  def with_id(child_id)
    allow(Child).to receive(:get).with(child_id).and_return @child
    allow(Child).to receive(:all).and_return [@child]
    allow(@child).to receive(:id).and_return child_id
    allow(@child).to receive(:last_updated_at).and_return(Date.today)
    self
  end

  def with_unique_identifier(identifier)
    allow(@child).to receive(:unique_identifier).and_return identifier
    self
  end

  def with_photo(image, image_id = 'img', current = true)
    photo = FileAttachment.new image_id, image.content_type, image.data

    allow(@child).to receive(:media_for_key).with(image_id).and_return photo
    allow(@child).to receive(:current_photo_key).and_return(image_id) if current
    allow(@child).to receive(:primary_photo).and_return photo if current
    self
  end

  def with_audio(audio, audio_id = 'audio', current = true)
    audio = double(FileAttachment, :content_type => audio.content_type, :mime_type => audio.mime_type, :data => StringIO.new(audio.data))
    allow(@child).to receive(:media_for_key).with(audio_id).and_return audio
    allow(@child).to receive(:audio).and_return audio if current
  end

  def with_no_photos
    allow(@child).to receive(:current_photo_key).and_return nil
    allow(@child).to receive(:media_for_key).and_return nil
    allow(@child).to receive(:primary_photo).and_return nil
    self
  end

  def with_rev(revision)
    allow(@child).to receive(:rev).and_return revision
    self
  end

  def with(hash)
    hash.each do |(key, value)|
      allow(@child).to receive(key).and_return(value)
    end
    self
  end
end
