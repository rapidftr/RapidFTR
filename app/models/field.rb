class Field < Hash
  include CouchRest::CastedModel
  include CouchRest::Validation
  
  property :name
  property :display_name
  property :help_text
  property :type
  property :option_strings
  property :allow_blank_default, :cast_as => 'boolean', :default => false

  attr_reader :options

  TEXT_FIELD = "text_field"
  TEXT_AREA = "textarea"
  RADIO_BUTTON = "radio_button"
  SELECT_BOX = "select_box"
  CHECK_BOX = "check_box"
  PHOTO_UPLOAD_BOX = "photo_upload_box"
  AUDIO_UPLOAD_BOX = "audio_upload_box"
  
  validates_presence_of :display_name
  validates_with_method :display_name, :method => :validate_unique
  
  def form
    base_doc
  end
  
  def validate_unique
    return true unless new? && form
    return [false, "Field already exists on this form"] if (form.fields.any? {|field| !field.new? && field.name == name})
    
    other_form = FormSection.get_form_containing_field name
    return [false, "Field already exists on form '#{other_form.name}'"] if other_form  != nil
    true
  end

  def initialize properties
    super properties
    if (option_strings)
      @options = FieldOption.create_field_options(name, option_strings)
    end
  end
  
  def self.new_check_box field_name, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => CHECK_BOX
  end

  def self.new_text_field field_name, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => TEXT_FIELD
  end

  def self.new_textarea field_name, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => TEXT_AREA
  end

  def self.new_photo_upload_box field_name, display_name  = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => PHOTO_UPLOAD_BOX
  end

  def self.new_audio_upload_box field_name, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => AUDIO_UPLOAD_BOX
  end

  def self.new_radio_button field_name, option_strings, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => RADIO_BUTTON, :option_strings => option_strings
  end

  def self.new_select_box field_name, option_strings, display_name = nil
    Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => SELECT_BOX, :option_strings => option_strings
  end

  def tag_id
    "child_#{name}"
  end

  def tag_name_attribute
    "child[#{name}]"
  end

  def select_options
    select_options = []
    select_options << ['(Select...)', ''] if allow_blank_default == '1'
    select_options += @options.collect { |option| [option.option_name, option.option_name] }
  end
end
