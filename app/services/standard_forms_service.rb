class StandardFormsService
  require "pry"

  def self.default_form_sections_for model_name
    if model_name == Child::FORM_NAME
      form_sections = RapidFTR::ChildrenFormSectionSetup.build_form_sections
    elsif model_name == Enquiry::FORM_NAME
      form_sections = RapidFTR::EnquiriesFormSectionSetup.build_form_sections
    end
  end

  def self.default_forms
    child_form = Form.new(name: Child::FORM_NAME)
    child_form.sections = RapidFTR::ChildrenFormSectionSetup.build_form_sections
    enquiry_form = Form.new(name: Enquiry::FORM_NAME)
    enquiry_form.sections = RapidFTR::EnquiriesFormSectionSetup.build_form_sections
    [child_form, enquiry_form]
  end

  def self.persist attributes_hash
    default_forms.each do |form|
      form_attributes = attributes_hash["forms"][form.name.downcase]
      if !form_attributes.nil? && form_attributes["user_selected"] == "1"
        form.sections = []
        form.save
      else
        form = Form.find_by_name(form.name)
      end
      persist_sections(form, form_attributes) if !form.nil?
    end
  end

  def self.persist_sections form, form_attributes
    form.reload_sections!
    sections_attributes = form_attributes["sections"] || {}
    form_sections = default_form_sections_for(form.name)
    selected_section_ids = sections_attributes
      .select {|key,attr| attr["user_selected"] == "1"}
      .collect {|key,attr| attr["id"]}
    form_sections.each do |section| 
      if selected_section_ids.include? section.unique_id
        section.form = form
        section.save
      end
    end
    form.reload_sections!
    persist_fields form, sections_attributes
  end

  def self.persist_fields form, sections_attributes
    form.reload_sections!
    form.sections.each do |section|
      section_attr = sections_attributes.nil? ? {} : sections_attributes[section.unique_id]
      if !section_attr.nil? && !section_attr.empty?
        fields = section_attr["fields"] || {}
        selected_fields = selected_fields(fields, section.fields)
        if section_attr["user_selected"] == "1"
          section.fields = selected_fields
        else
          section.merge_fields! selected_fields
        end
        section.save
      end
    end
  end

  def self.selected_fields fields_attributes={}, default_fields=[]
    user_selected_field_ids = fields_attributes.select { |field| field["user_selected"] == "1"} .collect(&:id)
    default_fields.select {|field| user_selected_field_ids.include? field.name }
  end
end
