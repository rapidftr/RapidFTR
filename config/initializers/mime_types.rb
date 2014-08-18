# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register_alias 'application/pdf', :pdf

Mime::Type.register 'audio/mp3', :mp3, ['audio/mpeg', 'audio/x-mpeg', 'audio/x-mp3', 'audio/mpeg3', 'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg, audio/x-mpegaudio']
Mime::Type.register 'audio/amr', :amr
Mime::Type.register 'audio/ogg', :ogg
Mime::Type.register 'image/jpeg', :jpg
