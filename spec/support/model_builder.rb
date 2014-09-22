module ModelBuilder
  def given_a(model)
    @model = double(model.to_sym)
    self
  end

  def with_id(model_id)
    allow(model_class.constantize).to receive(:get).with(model_id).and_return @model
    allow(model_class.constantize).to receive(:all).and_return [@model]
    allow(@model).to receive(:id).and_return model_id
    allow(@model).to receive(:last_updated_at).and_return(Date.today)
    self
  end

  def with_unique_identifier(identifier)
    allow(@model).to receive(:unique_identifier).and_return identifier
    self
  end

  def with_photo(image, image_id = 'img', current = true)
    photo = FileAttachment.new image_id, image.content_type, image.data

    allow(@model).to receive(:media_for_key).with(image_id).and_return photo
    allow(@model).to receive(:current_photo_key).and_return(image_id) if current
    allow(@model).to receive(:primary_photo).and_return photo if current
    self
  end

  def with_audio(audio, audio_id = 'audio', current = true)
    audio = double(FileAttachment, :content_type => audio.content_type, :mime_type => audio.mime_type, :data => StringIO.new(audio.data))
    allow(@model).to receive(:media_for_key).with(audio_id).and_return audio
    allow(@model).to receive(:audio).and_return audio if current
  end

  def with_no_photos
    allow(@model).to receive(:current_photo_key).and_return nil
    allow(@model).to receive(:media_for_key).and_return nil
    allow(@model).to receive(:primary_photo).and_return nil
    self
  end

  def with_rev(revision)
    allow(@model).to receive(:rev).and_return revision
    self
  end

  def with(hash)
    hash.each do |(key, value)|
      allow(@model).to receive(key).and_return(value)
    end
    self
  end
end
