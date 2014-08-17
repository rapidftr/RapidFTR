module AudioHelper
  def add_audio_file(audio_file, content_type)
    attachment = FileAttachment.from_file(audio_file, content_type, "audio", key_for_content_type(content_type))
    attach(attachment)
    setup_mime_specific_audio(attachment)
  end

  def recorded_audio=(audio_file_name = "")
    self["recorded_audio"] ||= audio_file_name
  end

  def audio=(audio_file)
    return unless audio_file.respond_to? :content_type
    @audio_file_name = audio_file.original_filename
    @audio = audio_file
    attachment = FileAttachment.from_uploadable_file(audio_file, "audio")
    self['recorded_audio'] = attachment.name
    attach(attachment)
    setup_original_audio(attachment)
    setup_mime_specific_audio(attachment)
  end

  def audio
    return nil if id.nil? || self['audio_attachments'].nil?
    attachment_key = self['audio_attachments']['original']
    return nil unless has_attachment? attachment_key

    data = read_attachment attachment_key
    content_type = self['_attachments'][attachment_key]['content_type']
    FileAttachment.new attachment_key, content_type, data
  end

  private

  def setup_mime_specific_audio(file_attachment)
    audio_attachments = (self['audio_attachments'] ||= {})
    content_type_for_key = file_attachment.mime_type.to_sym.to_s
    audio_attachments[content_type_for_key] = file_attachment.name
  end

  def setup_original_audio(attachment)
    audio_attachments = (self['audio_attachments'] ||= {})
    audio_attachments.clear
    audio_attachments['original'] = attachment.name
  end
end
