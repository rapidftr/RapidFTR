class FieldOption

  attr_reader :option_name

  def self.create_field_options(field_name, options)
    field_options = []
    options.each do |option|
      field_options << FieldOption.new(field_name, option)
    end
    field_options
  end

  def initialize(field_name, option)
    @field_name = field_name
    @option_name = option
  end

  def tag_name_attribute
    "child[#{@field_name}][#{@option_name}]"
  end

  def tag_id
    "child_#{@field_name}_#{@option_name.dehumanize}"
  end

end
