module MiniMagickConversions
  def to_thumbnail(size, path)
    thumbnail = MiniMagick::Image.from_file(path)
    thumbnail.resize "#{size}x#{size}"
    thumbnail.instance_eval "def content_type; 'image/#{File.extname(path).gsub(/^\./, '').downcase}'; end"

    def thumbnail.data
      self.to_blob
    end

    thumbnail
  end

  def to_image(blob)
    MiniMagick::Image.from_blob(blob)
  end
end