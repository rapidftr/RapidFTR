class FileAttachment
  attr_reader :name, :data, :content_type

  def initialize(name, content_type, data)
    @name = name
    @content_type = content_type
    @data = StringIO.new data
  end

  def FileAttachment.from_uploadable_file(file, name_prefix="file", name_suffix ="")
    from_file(file, file.content_type, name_prefix, name_suffix)
  end

  def FileAttachment.from_file(file, content_type, name_prefix="file", name_suffix ="")
    new generate_name(name_prefix, name_suffix), content_type, file.read
  end


  def FileAttachment.generate_name(name_prefix = "file", name_suffix = "")
    filename = [name_prefix, Clock.now.strftime('%Y-%m-%dT%H%M%S')]
    filename << name_suffix unless name_suffix.blank?
    filename.join('-')
  end
  
  def mime_type
    Mime::Type.lookup(self.content_type.downcase)
  end

end
