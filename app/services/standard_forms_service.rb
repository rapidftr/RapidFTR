class StandardFormsService
  FORMS_KEY = 'forms'
  SECTIONS_KEY = 'sections'
  FIELDS_KEY = 'fields'
  USER_SELECTED_KEY = 'user_selected'
  USER_SELECTED = '1'

  def self.persist(attributes_hash)
    RapidFTR::FormSetup.default_forms.each do |form|
      form_attr = attributes_hash.fetch(FORMS_KEY, {}).fetch(form.name.downcase, {})
      saved_form = persist_form(form, form_attr)
      next if saved_form.nil?

      sections_attr = form_attr.fetch(SECTIONS_KEY, {})
      persist_sections(saved_form, sections_attr)
    end
  end

  def self.persist_form(form, attributes)
    form.save if selected_by_user(attributes)
    Form.find_by_name(form.name)
  end

  def self.persist_sections(form, sections_attributes)
    sections_to_persist(form, sections_attributes).each do |section|
      section.form = form
      section.fields = RapidFTR::FormSetup.default_fields_for section
      section.save
    end
  end

  def self.sections_to_persist(form, sections_attributes)
    RapidFTR::FormSetup.default_sections_for(form.name).select do |section|
      sections_attributes[section.name] &&
        selected_by_user(sections_attributes[section.name])
    end
  end

  def self.selected_by_user(attr)
    !attr.nil? && attr[USER_SELECTED_KEY] == USER_SELECTED
  end
end
