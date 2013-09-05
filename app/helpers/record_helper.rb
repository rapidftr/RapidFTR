module RecordHelper
  include RapidFTR::Model
  include RapidFTR::Clock



  def set_creation_fields_for(user)
    self['created_by'] = user.try(:user_name)
    self['created_organisation'] = user.try(:organisation)
    self['created_at'] ||= RapidFTR::Clock.current_formatted_time
    self['posted_at'] = RapidFTR::Clock.current_formatted_time
  end

  def update_organisation
    self['created_organisation'] ||= created_by_user.try(:organisation)
  end

  def created_by_user
    User.find_by_user_name self['created_by'] unless self['created_by'].to_s.empty?
  end

  def set_updated_fields_for(user_name)
    self['last_updated_by'] = user_name
    self['last_updated_at'] = RapidFTR::Clock.current_formatted_time
  end

  def last_updated_by
    self['last_updated_by'] || self['created_by']
  end

  def last_updated_at
    self['last_updated_at'] || self['created_at']
  end

  def rotate_photo(angle)
    existing_photo = primary_photo
    image = MiniMagick::Image.from_blob(existing_photo.data.read)
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
  end

  def related_keys(for_key)
    self['_attachments'].keys.select { |check_key| check_key.starts_with? for_key }
  end

  def photo=(new_photos)
    return unless new_photos
    #basically to support any client passing a single photo param, only used by child_spec AFAIK
    if new_photos.is_a? Hash
      photos = new_photos.to_a.sort.map { |k, v| v }
    else
      photos = [new_photos]
    end
    self.photos = photos
  end

  def photos=(new_photos)
    @photos = []
    @new_photo_keys = new_photos.select { |photo| photo.respond_to? :content_type }.collect do |photo|
      @photos << photo
      attachment = FileAttachment.from_uploadable_file(photo, "photo-#{photo.path.hash}")
      attach(attachment)
      self["current_photo_key"] = attachment.name if photo.original_filename.include?(self["current_photo_key"].to_s)
      attachment.name
    end
  end

  def update_photo_keys
    return if @new_photo_keys.blank? && @deleted_photo_keys.blank?
    self['photo_keys'].concat(@new_photo_keys).uniq! if @new_photo_keys
    @deleted_photo_keys.each { |p|
      self['photo_keys'].delete p
      self['current_photo_key'] = self['photo_keys'].first if p == self['current_photo_key']
    } if @deleted_photo_keys

    self['current_photo_key'] ||= self['photo_keys'].first unless self['photo_keys'].include?(self['current_photo_key'])

    self['current_photo_key'] ||= @new_photo_keys.first if @new_photo_keys

    add_to_history(photo_changes_for(@new_photo_keys, @deleted_photo_keys)) unless id.nil?

    @new_photo_keys, @deleted_photo_keys = nil, nil
  end

  def photos
    return [] if self['photo_keys'].blank?
    self["photo_keys"].sort_by do |key|
      key == self["current_photo_key"] ? "" : key
    end.collect do |key|
      attachment(key)
    end
  end

  def photos_index
    return [] if self['photo_keys'].blank?
    self['photo_keys'].collect do |key|
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

  def update_history
    if field_name_changes.any?
      changes = changes_for(field_name_changes)
      (add_to_history(changes) unless (!self['histories'].empty? && (self['histories'].last["changes"].to_s.include? changes.to_s)))
    end
  end
  def ordered_histories
    (self["histories"] || []).sort { |that, this| DateTime.parse(this["datetime"]) <=> DateTime.parse(that["datetime"]) }
  end

  def add_creation_history
    self['histories'].unshift({
                                  'user_name' => created_by,
                                  'user_organisation' => organisation_of(created_by),
                                  'datetime' => created_at,
                                  'changes' => {'child' => {:created => created_at}}
                              })
  end

  def update_with_attachments(params, user)
    self['last_updated_by_full_name'] = user.full_name
    new_photo = params[:child].delete("photo")
    new_photo = (params[:child][:photo] || "") if new_photo.nil?
    new_audio = params[:child].delete("audio")
    update_properties_with_user_name(user.user_name, new_photo, params["delete_child_photo"], new_audio, params[:child])
  end

  def update_properties_with_user_name(user_name, new_photo, photo_names, new_audio, properties)
    update_properties(properties, user_name)
    self.delete_photos(photo_names)
    self.update_photo_keys
    self.photo = new_photo
    self.audio = new_audio
  end


  protected

  def add_to_history(changes)
    last_updated_user_name = last_updated_by
    self['histories'].unshift({
                                  'user_name' => last_updated_user_name,
                                  'user_organisation' => organisation_of(last_updated_user_name),
                                  'datetime' => last_updated_at,
                                  'changes' => changes})
  end

  def organisation_of(user_name)
    User.find_by_user_name(user_name).try(:organisation)
  end

  def field_name_changes
    field_names = field_definitions.map { |f| f.name }
    other_fields = [
        "flag", "flag_message",
        "reunited", "reunited_message",
        "investigated", "investigated_message",
        "duplicate", "duplicate_of"
    ]
    all_fields = field_names + other_fields
    all_fields.select { |field_name| changed?(field_name) }
  end
  def changes_for(field_names)
    field_names.inject({}) do |changes, field_name|
      changes.merge(field_name => {
          'from' => original_data[field_name],
          'to' => self[field_name]
      })
    end
  end

  def photo_changes_for(new_photo_keys, deleted_photo_keys)
    return if new_photo_keys.blank? && deleted_photo_keys.blank?
    {'photo_keys' => {'added' => new_photo_keys, 'deleted' => deleted_photo_keys}}
  end



  def changed?(field_name)
    return false if self[field_name].blank? && original_data[field_name].blank?
    return true if original_data[field_name].blank?
    if self[field_name].respond_to? :strip
      self[field_name].strip != original_data[field_name].strip
    else
      self[field_name] != original_data[field_name]
    end
  end

  def original_data
    (@original_data ||= Child.get(self.id) rescue nil) || self
  end

  def is_filled_in? field
    !(self[field.name].nil? || self[field.name] == field.default_value || self[field.name].to_s.empty?)
  end

  private

  def update_properties(properties, user_name)
    properties['histories'] = remove_newly_created_media_history(properties['histories'])
    should_update = self["last_updated_at"] && properties["last_updated_at"] ? (DateTime.parse(properties['last_updated_at']) > DateTime.parse(self['last_updated_at'])) : true
    if should_update
      properties.each_pair do |name, value|
        if name == "histories"
          merge_histories(properties['histories'])
        else
          self[name] = value unless value == nil
        end
        self["#{name}_at"] = RapidFTR::Clock.current_formatted_time if ([:flag, :reunited].include?(name.to_sym) && value.to_s == 'true')
      end
      self.set_updated_fields_for user_name
    else
      merge_histories(properties['histories'])
    end
  end

  def merge_histories(given_histories)
    current_histories = self['histories']
    to_be_merged = []
    (given_histories || []).each do |history|
      matched = current_histories.find do |c_history|
        c_history["user_name"] == history["user_name"] && c_history["datetime"] == history["datetime"] && c_history["changes"].keys == history["changes"].keys
      end
      to_be_merged.push(history) unless matched
    end
    self["histories"] = current_histories.push(to_be_merged).flatten!
  end

  def remove_newly_created_media_history(given_histories)
    (given_histories || []).delete_if do |history|
      (history["changes"]["current_photo_key"].present? and history["changes"]["current_photo_key"]["to"].present? and !history["changes"]["current_photo_key"]["to"].start_with?("photo-")) ||
          (history["changes"]["recorded_audio"].present? and history["changes"]["recorded_audio"]["to"].present? and !history["changes"]["recorded_audio"]["to"].start_with?("audio-"))
    end
    given_histories
  end

  def attachment(key)
    begin
      data = read_attachment key
      content_type = self['_attachments'][key]['content_type']
    rescue
      return nil
    end
    FileAttachment.new key, content_type, data
  end



end