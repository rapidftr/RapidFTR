module FormSectionHelper
  def sorted_highlighted_fields
    FormSection.sorted_highlighted_fields
  end

  def forms_for_display
    FormSection.all.sort_by{ |form| form.name || "" }.map{ |form| [form.name, form.unique_id] }
  end

  def url_for_form_section_field(form_section_id, field)
    field.new? ? form_section_fields_path(form_section_id) : form_section_field_path(form_section_id, field.name)
  end

  def url_for_form_section(form_section, form)
    form_section.new? ? form_form_sections_path(form.id) : form_section_path(form_section.unique_id)
  end
end
