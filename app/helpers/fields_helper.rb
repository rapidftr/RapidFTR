module FieldsHelper

  def display_options field
    field.option_strings.collect { |f| '"'+f+'"' }.join(", ")
  end

  def forms_for_display
    FormSection.all.sort_by{ |form| form.name || "" }.map{ |form| [form.name, form.unique_id] }
  end
end
