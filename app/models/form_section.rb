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

  def self.create_form_section_from_template section_name, template, child=Child.new
    form = FormSection.new section_name
    template.each do |field|
      field_value = child[field['name']]
      form.add_field(Field.new(field['name'], field['type'], field['options'] || [], field_value))
    end
    return form
  end

  def name
    fields.each do |field|
      if field.name == 'name'
         return field.value
      end
    end
  end

end