module ChildBuilder

  def given_a_child
    @child = mock(:child)
    self
  end

  def with_id(child_id)
    Child.stub!(:get).with(child_id).and_return @child
    Child.stub!(:all).and_return [@child]
    @child.stub!(:id).and_return child_id
    self
  end

  def with_photo(image, image_id = "img", current = true)
    photo = mock(FileAttachment, {:content_type => image.content_type, :data => StringIO.new(image.read)})
    @child.stub!(:media_for_key).with(image_id).and_return photo
    @child.stub!(:photo).and_return photo if current
    self
  end

  def with_audio(audio, audio_id ="audio", current = true)
    audio = mock(FileAttachment, {:content_type => audio.content_type, :data => StringIO.new(audio.read)})
    @child.stub!(:media_for_key).with(audio_id).and_return audio
    @child.stub!(:audio).and_return audio if current
  end

  def with_no_photos
    @child.stub!(:photo_for_key).and_return nil
    @child.stub!(:photo).and_return nil
    self
  end

  def with_rev(revision)
    @child.stub!(:rev).and_return revision
    self
  end

end