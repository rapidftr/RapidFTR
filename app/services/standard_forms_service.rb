class StandardFormsService

  FORMS_KEY = "forms"
  SECTIONS_KEY = "sections"
  FIELDS_KEY = "fields"
  USER_SELECTED_KEY = "user_selected"
  USER_SELECTED = "1"

  def self.persist(attributes_hash)
    RapidFTR::FormSetup.default_forms.each do |form|
      form_attr = attributes_hash.fetch(FORMS_KEY, {}).fetch(form.name.downcase, {})
      saved_form = persist_form(form, form_attr)

      unless saved_form.nil?
        sections_attr = form_attr.fetch(SECTIONS_KEY, {})
        saved_sections = persist_sections(saved_form, sections_attr)

        saved_sections.each do |s|
          fields_attr = sections_attr.fetch(s.name, {}).fetch(FIELDS_KEY, {})
          persist_fields(s, fields_attr)
        end
      end
    end
  end

  def self.persist_form(form, attributes)
    form.save if selected_by_user(attributes)
    Form.find_by_name(form.name)
  end

  def self.persist_sections(form, sections_attributes)
    sections_to_persist(form, sections_attributes).each do |section|
      section.form = form
      section.fields = []
      section.save
    end
    form.reload_sections!
    form.sections
  end

  def self.persist_fields(section, fields_attributes)
    section.merge_fields! fields_to_persist(section, fields_attributes)
    section.save
  end

  def self.selected_by_user(attr)
    !attr.nil? && attr[USER_SELECTED_KEY] == USER_SELECTED
  end

  def self.fields_to_persist(section, fields_attributes = {})
    RapidFTR::FormSetup.default_fields_for(section).select do |field|
      fields_attributes[field.name] &&
        selected_by_user(fields_attributes[field.name])
    end
  end

  def self.sections_to_persist(form, sections_attributes)
    RapidFTR::FormSetup.default_sections_for(form.name).select do |section|
      sections_attributes[section.name] &&
        selected_by_user(sections_attributes[section.name])
    end
  end
end
