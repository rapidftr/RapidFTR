database = FormSection.database
form_sections = database.documents['rows'].select { |row| !row['id'].include?('_design') }

def rename_attributes(obj, hash)
  hash.each do |from, to|
    obj[to] = obj.delete(from) if obj[from]
  end
end

form_sections.each do |row|
  form_section = database.get(row['id'])
  rename_attributes form_section, 'enabled' => 'visible', 'name' => 'name_en', 'help_text' => 'help_text_en', 'description' => 'description_en'

  form_section['fields'].each do |field|
    rename_attributes field, 'option_strings' => 'option_strings_text_en', 'enabled' => 'visible', 'help_text' => 'help_text_en', 'display_name' => 'display_name_en'
    field['option_strings_text_en'] = field['option_strings_text_en'].join("\n") if field.include?('option_strings_text_en') && field['option_strings_text_en'].is_a?(Array)
  end

  form_section.save
end
