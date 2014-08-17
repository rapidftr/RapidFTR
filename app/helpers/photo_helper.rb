module PhotoHelper
  def rotate_photo(angle)
    existing_photo = primary_photo
    image = MiniMagick::Image.read(existing_photo.data.read)
    image.rotate(angle)

    attachment = FileAttachment.new(existing_photo.name, existing_photo.content_type, image.to_blob, self)

    photo_key_index = self['photo_keys'].find_index(existing_photo.name)
    self['photo_keys'].delete_at(photo_key_index)
    self['_attachments'].keys.each do |key|
      delete_attachment(key) if key == existing_photo.name || key.starts_with?(existing_photo.name)
    end

    self['photo_keys'].insert(photo_key_index, existing_photo.name)
    attach(attachment)
  end

  def delete_photos(photo_names)
    return unless photo_names
    photo_names = photo_names.keys if photo_names.is_a? Hash
    photo_names.map { |x| related_keys(x) }.flatten.each do |key|
      photo_key_index = self['photo_keys'].find_index(key)
      self['photo_keys'].delete_at(photo_key_index) unless photo_key_index.nil?
      delete_attachment(key)
    end

    @deleted_photo_keys ||= []
    @deleted_photo_keys.concat(photo_names)
    update_photo_keys
  end

  def photo=(new_photos)
    return unless new_photos
    # basically to support any client passing a single photo param, only used by child_spec AFAIK
    if new_photos.is_a? Hash
      photos = new_photos.to_a.sort.map { |k, v| v }
    else
      photos = [new_photos]
    end
    self.photos = photos
  end

  def photos=(new_photos)
    @photos = []
    @new_photo_keys = new_photos.select { |photo| photo.respond_to? :content_type }.map do |photo|
      @photos << photo
      attachment = FileAttachment.from_uploadable_file(photo, "photo-#{photo.path.hash}")
      attach(attachment)
      self["current_photo_key"] = attachment.name if photo.original_filename.include?(self["current_photo_key"].to_s)
      attachment.name
    end
  end

  # TODO: #40: Why two methods - delete_photos (above) & update_photo_keys - Refactor this
  def update_photo_keys
    return if @new_photo_keys.blank? && @deleted_photo_keys.blank?
    self['photo_keys'].concat(@new_photo_keys).uniq! if @new_photo_keys
    @deleted_photo_keys.each do |p|
      self['photo_keys'].delete p
      self['current_photo_key'] = self['photo_keys'].first if p == self['current_photo_key']
    end if @deleted_photo_keys

    self['current_photo_key'] ||= self['photo_keys'].first unless self['photo_keys'].include?(self['current_photo_key'])

    self['current_photo_key'] ||= @new_photo_keys.first if @new_photo_keys

    add_to_history(photo_changes_for(@new_photo_keys, @deleted_photo_keys)) unless id.nil?

    @new_photo_keys, @deleted_photo_keys = nil, nil
  end

  def photos
    return [] if self['photo_keys'].blank?
    self["photo_keys"].sort_by do |key|
      key == self["current_photo_key"] ? "" : key
    end.map do |key|
      attachment(key)
    end
  end

  def photo_changes_for(new_photo_keys, deleted_photo_keys)
    return if new_photo_keys.blank? && deleted_photo_keys.blank?
    {'photo_keys' => {'added' => new_photo_keys, 'deleted' => deleted_photo_keys}}
  end

  def photos_index
    return [] if self['photo_keys'].blank?
    self['photo_keys'].map do |key|
      {
        :photo_uri => child_photo_url(self, key),
        :thumbnail_uri => child_photo_url(self, key)
      }
    end
  end

  def primary_photo
    key = self['current_photo_key']
    (key == "" || key.nil?) ? nil : attachment(key)
  end

  def primary_photo_id
    self['current_photo_key']
  end

  def primary_photo_id=(photo_key)
    unless self['photo_keys'].include?(photo_key)
      raise I18n.t("errors.models.child.primary_photo_id", :photo_id => photo_key)
    end
    self['current_photo_key'] = photo_key
  end
end
