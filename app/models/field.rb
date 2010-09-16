class Field < Hash
  include CouchRest::CastedModel
  include CouchRest::Validation
  
  property :name
  property :help_text
  property :type
  property :option_strings

  attr_reader :options

  TEXT_FIELD = "text_field"
  TEXT_AREA = "textarea"
  RADIO_BUTTON = "radio_button"
  SELECT_BOX = "select_box"
  CHECK_BOX = "check_box"
  PHOTO_UPLOAD_BOX = "photo_upload_box"
  AUDIO_UPLOAD_BOX = "audio_upload_box"

  def initialize properties
    super properties
    if (option_strings)
      @options = FieldOption.create_field_options(name, option_strings)
    end
  end

  def self.new_check_box field_name
    Field.new :name => field_name, :type => CHECK_BOX
  end

  def self.new_text_field field_name
    Field.new :name => field_name, :type => TEXT_FIELD
  end

  def self.new_textarea field_name
    Field.new :name => field_name, :type => TEXT_AREA
  end

  def self.new_photo_upload_box field_name
    Field.new :name => field_name, :type => PHOTO_UPLOAD_BOX
  end

  def self.new_audio_upload_box field_name
    Field.new :name => field_name, :type => AUDIO_UPLOAD_BOX
  end


  def self.new_radio_button field_name, option_strings
    Field.new :name => field_name, :type => RADIO_BUTTON, :option_strings => option_strings
  end

  def self.new_select_box field_name, option_strings
    Field.new :name => field_name, :type => SELECT_BOX, :option_strings => option_strings
  end

  def tag_id
    "child_#{name}"
  end

  def tag_name_attribute
    "child[#{name}]"
  end

  def select_options
    select_options = @options.collect { |option| [option.option_value, option.option_name] }
    return select_options
  end

end
