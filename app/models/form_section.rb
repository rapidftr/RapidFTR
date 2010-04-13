class FormSection

  attr_reader :fields, :section_name

  def initialize section_name=""
    @section_name = section_name
    @fields = []
  end

  def add_text_field field_name
    @fields << Field.new_text_field(field_name)
  end

  def add_field field
    @fields << field
  end

  def self.create_form_section_from_template section_name, template
    form = FormSection.new section_name
    template.each do |field|
      form.add_field(Field.new(field['name'], field['type'], field['options'] || []))
    end
    return form
  end

end