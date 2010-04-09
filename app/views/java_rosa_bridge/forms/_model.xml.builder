xml.model {
  xml.instance {
    xml.xform {
      @fields.each do |field|
        xml.tag!( field.name )
      end
    }
  }

  @fields.each do |field|
    bind_type = case field.type.to_sym
    when :photo_upload_box
      'binary'
    else
      'string'
    end

      xml.bind(:nodeset => "/xform/#{field.name}", :type => bind_type)
  end
}
