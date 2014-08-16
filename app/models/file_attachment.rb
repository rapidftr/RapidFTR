class FileAttachment
  include RapidFTR::Model
  attr_reader :name, :content_type, :child

  def initialize(name, content_type, data, child = nil)
    @name = name
    @content_type = content_type
    @data = data
    @child = child
  end

  def data
    StringIO.new @data
  end

  def self.from_uploadable_file(file, name_prefix = "file", name_suffix = "", child = nil)
    from_file(file, file.content_type, name_prefix, name_suffix, child)
  end

  def self.from_file(file, content_type, name_prefix = "file", name_suffix = "", child = nil)
    file = file.tempfile if file.respond_to?(:tempfile)
    new generate_name(name_prefix, name_suffix), content_type, File.binread(file), child
  end

  def self.generate_name(name_prefix = "file", name_suffix = "")
    filename = [name_prefix, Clock.now.strftime('%Y-%m-%dT%H%M%S')]
    filename << name_suffix unless name_suffix.blank?
    filename.join('-')
  end

  def mime_type
    Mime::Type.lookup(self.content_type.downcase)
  end

  def resize(new_size)
    new_name = "#{name}_#{new_size}"
    return child.media_for_key(new_name) if child && child.has_attachment?(new_name)

    resized_data = resized_blob(new_size)
    new_attachment = FileAttachment.new new_name, content_type, resized_data, child

    unless child.nil?
      child.attach new_attachment
      child.save
    end

    new_attachment
  end

  private

  def resized_blob(new_size)
    image = MiniMagick::Image.read(data.read)
    image.resize new_size
    image.to_blob
  end

end
