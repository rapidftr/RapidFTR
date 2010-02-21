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

  def self.get_child_view_for_template template
    child_view = ChildView.new
    template.each do |field|
      child_view.add_field(Field.new field['name'], field['type'], field['options'] || [])
    end
    return child_view
  end
end