class FieldOption

  attr_reader :option_name
  attr_reader :option_value

  def self.create_field_options field_name, options
    field_options = []
    options.each do |option|
      field_options << FieldOption.new(field_name, option)
    end
    return field_options
  end

  def initialize field_name, option
    @field_name = field_name
    @option_key_value = option.split(',')
    if @option_key_value.size >= 2
      @option_name = @option_key_value[0]
      @option_key_value.shift
      @option_value = @option_key_value.join(",")
    else
      @option_name = option
      @option_value = option
    end
  end

  def tag_name_attribute
    "child[#{@field_name}][#{@option_name}]"
  end

  def tag_id
    "child_#{@field_name}_#{@option_name.downcase}"
  end

end
