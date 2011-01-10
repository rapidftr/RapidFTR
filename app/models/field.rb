class Field < Hash
  include CouchRest::CastedModel
  include CouchRest::Validation
  
  property :name
  property :display_name
  property :enabled, :cast_as => 'boolean', :default => true
  property :help_text
  property :type
  property :option_strings

  attr_reader :options

  TEXT_FIELD = "text_field"
  TEXT_AREA = "textarea"
  RADIO_BUTTON = "radio_button"
  SELECT_BOX = "select_box"
  CHECK_BOX = "check_box"
  NUMERIC_FIELD = "numeric_field"
  PHOTO_UPLOAD_BOX = "photo_upload_box"
  AUDIO_UPLOAD_BOX = "audio_upload_box"
  DATE_FIELD = "date_field"
  NUMERIC_FIELD = "numeric_field"
   
  FIELD_FORM_TYPES = {  TEXT_FIELD       => "basic", 
                        TEXT_AREA        => "basic",
                        RADIO_BUTTON     => "multiple_choice",
                        SELECT_BOX       => "multiple_choice",
                        CHECK_BOX        => "basic",
                        PHOTO_UPLOAD_BOX => "basic",
                        AUDIO_UPLOAD_BOX => "basic",
                        DATE_FIELD       => "basic",
                        NUMERIC_FIELD    => "basic"}
  
  validates_presence_of :display_name 
  validates_with_method :display_name, :method => :validate_unique
  validates_with_method :option_strings, :method => :validate_has_2_options
  
  def form
    base_doc
  end
  
  def form_type
    FIELD_FORM_TYPES[type]
  end
  
  def validate_has_2_options
    return true unless (type == RADIO_BUTTON || type == SELECT_BOX)
    return [false, "Field must have at least 2 options"] if option_strings == nil || option_strings.length < 2
    true
  end
  
  def validate_unique
    return true unless new? && form
    return [false, "Field already exists on this form"] if (form.fields.any? {|field| !field.new? && field.name == name})
    other_form = FormSection.get_form_containing_field name
    return [false, "Field already exists on form '#{other_form.name}'"] if other_form  != nil
    true
  end

  def initialize properties
    properties["enabled"] = true if properties["enabled"] == nil
    self.attributes = properties
  end
  
  def attributes= properties
    option_strings_text = properties.delete('option_strings_text')
    super properties
    self.option_strings_text = option_strings_text
    self.name = display_name.dehumanize if display_name
    if (option_strings)
      @options = FieldOption.create_field_options(name, option_strings)
    end
  end
  
  def option_strings_text= value
    if value && value.class != Array
      self[:option_strings] = value.split("\n").select {|x| not "#{x}".strip.empty? }.map(&:rstrip)
    end
  end
  
  def option_strings_text
    return "" unless  self[:option_strings]
    self[:option_strings].join("\n") 
  end
  
  def tag_id
    "child_#{name}"
  end

  def tag_name_attribute
    "child[#{name}]"
  end

  def select_options
    select_options = []
    select_options << ['(Select...)', '']
    select_options += @options.collect { |option| [option.option_name, option.option_name] }
  end
  
  #TODO - remove this is just for testing
  def self.new_field(type, name, options=[])
    Field.new :type => type, :name => name, :display_name => name, :enabled => true, :option_strings => options
  end
  
  def self.new_check_box field_name, display_name = nil
    Field.new :name => field_name, :display_name=>display_name, :type => CHECK_BOX
  end
  
  def self.new_text_field field_name, display_name = nil
    field = Field.new :name => field_name, :display_name=>display_name||field_name.humanize, :type => TEXT_FIELD
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
end
