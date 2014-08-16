class Field
  include CouchRest::Model::CastedModel
  include RapidFTR::Model
  include PropertiesLocalization

  #track down whether the instance is new or not.
  #CouchRest::Model::Embeddable new? method rely
  #on the new? of the parent object. This make not
  #possible to know if the embedded item already
  #exists or not in the database. The parent object
  #is responsible to set the flag.
  #document_saved nil or false consider the field as new.
  #TODO move to a monkey patch for CouchRest::Model::Embeddable
  attr_accessor :document_saved

  property :name
  property :visible, TrueClass, :default => true
  property :type
  property :highlight_information, HighlightInformation
  property :editable, TrueClass, :default => true
  localize_properties [:display_name, :help_text, :option_strings_text]
  attr_reader :options
  property :base_language, :default => 'en'

  FIELD_TYPES = [
    TEXT_FIELD = "text_field",
    TEXT_AREA = "textarea",
    RADIO_BUTTON = "radio_button",
    SELECT_BOX = "select_box",
    CHECK_BOXES = "check_boxes",
    NUMERIC_FIELD = "numeric_field",
    PHOTO_UPLOAD_BOX = "photo_upload_box",
    AUDIO_UPLOAD_BOX = "audio_upload_box",
    DATE_FIELD = "date_field"
  ]

  validates_presence_of "display_name_#{I18n.default_locale}", :message => I18n.t("errors.models.field.display_name_presence")
  validate :validate_unique_name
  validate :validate_has_2_options
  validate :validate_has_a_option
  validate :validate_name_format
  validate :valid_presence_of_base_language_name

  def validate_name_format
    special_characters = /[*!@#%$\^]/
    white_spaces = /^(\s+)$/
    if (display_name =~ special_characters) || (display_name =~ white_spaces)
      errors.add(:display_name, I18n.t("errors.models.field.display_name_format"))
      return false
    else
      return true
    end
  end

  def valid_presence_of_base_language_name
    if base_language == nil
      self.base_language = 'en'
    end
    base_lang_display_name = self.send("display_name_#{base_language}")
    if base_lang_display_name.nil? || base_lang_display_name.empty?
      errors.add(:display_name, I18n.t("errors.models.form_section.presence_of_base_language_name", :base_language => base_language))
    end
  end

  #Override new? method to not rely on the new? of the parent object.
  #TODO move to a monkey patch for CouchRest::Model::Embeddable
  def new?
    !@document_saved
  end
  alias_method :new_record?, :new?

  def form
    base_doc
  end

  def display_type
    case type
    when PHOTO_UPLOAD_BOX then 'photo'
    when AUDIO_UPLOAD_BOX then 'audio'
    else 'basic'
    end
  end

  def display_name_for_field_selector
    hidden_text = self.visible? ? "" : " (Hidden)"
    "#{display_name}#{hidden_text}"
  end

  def initialize properties = {}
    self.visible = true if properties["visible"].nil?
    self.highlight_information = HighlightInformation.new
    self.editable = true if properties["editable"].nil?
    self.attributes = properties
    create_unique_id
  end

  def attributes= properties
    super properties
    if option_strings
      @options = FieldOption.create_field_options(name, option_strings)
    end
  end

  def option_strings= value
    if value
      value = value.gsub(/\r\n?/, "\n").split("\n") if value.is_a?(String)
      self.option_strings_text = value.select { |x| not "#{x}".strip.empty? }.map(&:rstrip).join("\n")
    end
  end

  def option_strings
    return [] unless self.option_strings_text
    return self.option_strings_text if self.option_strings_text.is_a?(Array)
    self.option_strings_text.gsub(/\r\n?/, "\n").split("\n")
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

  def is_highlighted?
    highlight_information[:highlighted]
  end

  def highlight_with_order order
    highlight_information[:highlighted] = true
    highlight_information[:order] = order
  end

  def unhighlight
    self.highlight_information = HighlightInformation.new
  end

  def self.find_by_name(name)
    Field.by_name(:key => name.downcase).first
  end

  private

  def create_unique_id
    self.name = UUIDTools::UUID.random_create.to_s.split('-').first if self.name.nil?
  end

  def validate_has_2_options
    return true unless type == RADIO_BUTTON || type == SELECT_BOX
    return errors.add(:option_strings, I18n.t("errors.models.field.has_2_options")) if option_strings == nil || option_strings.length < 2
    true
  end

  def validate_has_a_option
    return true unless (type == CHECK_BOXES)
    return errors.add(:option_strings, I18n.t("errors.models.field.has_1_option")) if option_strings == nil || option_strings.length < 1
    true
  end

  def validate_unique_name
    return unless form
    return errors.add(:name, I18n.t("errors.models.field.unique_name_this")) if form.fields.any? { |field| !field.equal?(self) && field.name == name }
    other_form = FormSection.get_form_containing_field name
    return errors.add(:name, I18n.t("errors.models.field.unique_name_other", :form_name => other_form.name)) if other_form != nil && form.id != other_form.id
    true
  end

end
