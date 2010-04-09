@fields.each do |field|
  case field.type.to_sym
  when :text_field
    xml.input( :ref => field.name ) {
      xml.label field.name.humanize 
    }
  when :radio_button, :select_box
    xml.select1( :ref => field.name ) {
      xml.label field.name.humanize 
      field.options.each do |option|
        xml.item {
          xml.label( option.option_name )
          xml.value( option.option_name )
        }
      end
    }
  when :photo_upload_box
    xml.upload( :ref => field.name, :mediatype => 'image/*' ) {
      xml.label field.name.humanize
    }
  end
end

