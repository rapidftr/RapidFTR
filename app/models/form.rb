class Form < CouchRest::Model::Base
  include RapidFTR::Model
  use_database :form

  before_destroy :remove_form_sections

  property :name

  attr_accessor :sections

  design do
    view :by_name
  end

  def self.find_or_create_by_name(name)
    form = find_by_name(name)
    form.nil? ? Form.create(:name => name) : form
  end

  def self.find_by_name(name)
    Form.by_name.key(name).first
  end

  def update_title_field(field_name, value)
    sections.each do |s|
      field_to_update =  s.get_field_by_name(field_name)
      field_to_update.title_field = value unless field_to_update.nil?
      s.without_update_hooks { s.save(:validate => false) }
    end
  end

  def title_fields
    highlighted_fields.select { |f| f.title_field? }
  end

  def sections
    @sections ||= FormSection.all.all.select { |fs| fs.form == self }
  end

  def reload_sections!
    @sections = FormSection.all.all.select { |fs| fs.form == self }
  end

  def sections=(sections)
    sections.each { |s| s.form = self }
    @sections = sections
  end

  def highlighted_fields
    sections.map do |form_section|
      form_section.fields.select { |field| field.highlighted? }
    end.flatten
  end

  def sorted_highlighted_fields
    highlighted_fields.sort { |field1, field2| field1.highlight_information.order.to_i <=> field2.highlight_information.order.to_i }
  end

  private

  def remove_form_sections
    form_sections = FormSection.all.all.select { |fs| fs.form == self }
    unless form_sections.nil?
      form_sections.each { |fs| fs.destroy }
    end
  end
end
