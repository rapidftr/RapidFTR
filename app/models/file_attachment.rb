class FileAttachment
  attr_reader :name, :data, :content_type

  def initialize(name, content_type, data)
    @name = name
    @content_type = content_type
    @data = StringIO.new data
  end

  def FileAttachment.from_uploadable_file(file, name_prefix="file")
    new generate_name(name_prefix), file.content_type, file.read
  end

  def FileAttachment.generate_name(prefix = "file")
    "#{prefix}-#{Time.now.strftime('%Y-%m-%dT%H%M%S')}"    
  end

end