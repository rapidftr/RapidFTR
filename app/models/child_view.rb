class ChildView

  attr_reader :fields

  def initialize
    @fields = []
  end

  def add_text_field field_name
    @fields << Field.new_text_field(field_name)
  end

  def add_field field
    @fields << field
  end

  def self.create_child_view_from_template template, child=Child.new
    child_view = ChildView.new
    template.each do |field|
      field_value = child[field['name']]
      child_view.add_field(Field.new(field['name'], field['type'], field['options'] || [], field_value))
    end
    return child_view
  end

end