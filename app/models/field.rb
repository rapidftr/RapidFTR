class Field
  TEXT_FIELD = "text_field"
  RADIO_BUTTON = "radio_button"

  attr_reader :name, :type, :options

  def initialize field_name, field_type, field_options = []
    @name = field_name
    @type = field_type
    @options = field_options
  end

  def tag_id
    "child_#{@name}"
  end

  def self.new_text_field field_name
    Field.new field_name, TEXT_FIELD
  end

  def self.new_radio_button field_name, options
    Field.new field_name, RADIO_BUTTON, options
  end

  def tag_name_attribute
    "child[#{@name}]"
  end
end