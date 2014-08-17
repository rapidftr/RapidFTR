module FieldsHelper
  def display_options(field)
    field.option_strings.map { |f| '"' + f + '"' }.join(", ")
  end

  def form_sections_for_display(form)
    FormSection.all_form_sections_for(form.name).sort_by { |form_section| form_section.name || "" }.map { |form_section| [form_section.name, form_section.unique_id] }
  end
end
