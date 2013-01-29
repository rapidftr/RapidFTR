FormSection.all.each do |form_section|
  form_section.name_en = form_section.name
  form_section.description_en = form_section.description
  form_section.help_text_en = form_section.help_text

  form_section.visible = form_section.enabled?

  unless form_section.perm_enabled? then
    form_section.fixed_order = false
  else
    form_section.fixed_order = true
    form_section.perm_visible = true
  end

  form_section.fields.each do |field|
    field.display_name_en = field.display_name
    field.help_text_en = field.help_text
    field.option_strings_text_en = field.option_strings_text
  end
  form_section.save!
end
