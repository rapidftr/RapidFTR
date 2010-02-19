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
end