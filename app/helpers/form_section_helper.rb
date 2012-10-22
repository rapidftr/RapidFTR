module FormSectionHelper
  def sorted_highlighted_fields
    FormSection.sorted_highlighted_fields
  end

  def forms_for_display
    FormSection.all.sort_by(&:name).map { |form| [form.name, form.unique_id] }
  end
end
