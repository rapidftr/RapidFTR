class FileAttachment
  attr_reader :name, :data, :content_type

  def initialize(name, content_type, data)
    @name = name
    @content_type = content_type
    @data = StringIO.new data
  end

  def self.from_uploadable_file(file, name_prefix="file")
    name = "#{name_prefix}-#{Time.now.strftime('%Y-%m-%dT%H%M%S')}"
    new name, file.content_type, file.read
  end

end