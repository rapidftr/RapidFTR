module AttachmentHelper
  def attach(attachment)
    create_attachment :name => attachment.name,
                      :content_type => attachment.content_type,
                      :file => attachment.data
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

  def media_for_key(media_key)
    data = read_attachment media_key
    content_type = self['_attachments'][media_key]['content_type']
    FileAttachment.new media_key, content_type, data, self
  end

  def related_keys(for_key)
    self['_attachments'].keys.select { |check_key| check_key.starts_with? for_key }
  end
end
