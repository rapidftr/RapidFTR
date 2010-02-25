class Field
  
  TEXT_FIELD = "text_field"
  RADIO_BUTTON = "radio_button"
  SELECT_BOX = "select_box"
  CHECK_BOX = "check_box"

  attr_reader :name, :type, :options, :value

  def initialize field_name, field_type, field_options = [], value = nil
    @name = field_name
    @type = field_type
    @options = FieldOption.create_field_options(field_name, field_options)
    @value = value
  end

  def self.new_text_field field_name
    Field.new field_name, TEXT_FIELD
  end

  def self.new_radio_button field_name, options
    Field.new field_name, RADIO_BUTTON, options
  end

  def self.new_select_box field_name, options
    Field.new field_name, SELECT_BOX, options
  end


  def self.new_check_box field_name
    Field.new field_name, CHECK_BOX
  end

  def tag_id
    "child_#{@name}"
  end

  def tag_name_attribute
    "child[#{@name}]"
  end

  def select_options
    default_empty_option = [["",""]]
    select_options = @options.collect { |option| [option.option_name, option.option_name] }
    return default_empty_option.concat(select_options)
  end
end