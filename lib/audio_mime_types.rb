class AudioMimeTypes
  def self.browser_playable? mime_type
    [Mime::MP3, Mime::OGG, Mime::AMR].include? mime_type
  end
  def self.to_file_extension mime_type
    "." + mime_type.to_sym.to_s
  end
end