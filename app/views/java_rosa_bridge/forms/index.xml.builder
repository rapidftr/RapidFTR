xml.instruct!
xml.forms {
  @available_forms.each do |id, human_name|
    xml.form( human_name, :url => java_rosa_bridge_form_url(id) )
  end
}
