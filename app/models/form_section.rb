class FormSection < CouchRest::Model::Base
  include RapidFTR::Model
  include PropertiesLocalization
  use_database :form_section
  localize_properties [:name, :help_text, :description]
  property :unique_id
  property :visible, TrueClass, :default => true
  property :order, Integer
  property :fields, [Field]
  property :editable, TrueClass, :default => true
  property :fixed_order, TrueClass, :default => false
  property :perm_visible, TrueClass, :default => false
  property :perm_enabled, TrueClass
  property :validations, [String]
  property :base_language, :default => 'en'

  design do
    view :by_unique_id
    view :by_order
  end
  validates "name_#{I18n.default_locale}", :presence => {:message => I18n.t('errors.models.form_section.presence_of_name')}
  validate :valid_presence_of_base_language_name
  validate :validate_name_format
  validate :validate_unique_id
  validate :validate_unique_name
  validate :validate_visible_field
  validate :validate_fixed_order
  validate :validate_perm_visible

  after_create :update_indices
  after_update :update_indices
  after_save :update_child_matches

  belongs_to :form

  def update_indices
    Child.update_solr_indices
    Enquiry.update_solr_indices
  end

  def update_child_matches
    Enquiry.delay.update_all_child_matches
  end

  def without_update_hooks
    FormSection.skip_callback(:update, :after, :update_indices)
    FormSection.skip_callback(:save, :after, :update_child_matches)
    yield if block_given?
    FormSection.set_callback(:update, :after, :update_indices)
    FormSection.set_callback(:save, :after, :update_child_matches)
  end

  def valid_presence_of_base_language_name
    if base_language.nil?
      self.base_language = 'en'
    end
    base_lang_name = send("name_#{base_language}")
    [!(base_lang_name.nil? || base_lang_name.empty?), I18n.t('errors.models.form_section.presence_of_base_language_name', :base_language => base_language)]
  end

  # If everything goes well when saving, CastedBy items
  # should flag as saved.
  # TODO: move to a monkey patch for CouchRest::Model::Base
  before_save do
    flag_saved_embedded_properties
  end

  def initialize(properties = {}, options = {})
    self['fields'] = []
    super properties, options
    create_unique_id
    #:directly_set_attributes is set to true when the object is built from the database.
    # flag as saved CastedArray and CastedHash fields.
    # TODO: move to a monkey patch for CouchRest::Model::Base
    if options[:directly_set_attributes]
      flag_saved_embedded_properties
    end
  end

  alias_method :to_param, :unique_id

  class << self
    def enabled_by_order
      by_order.select(&:visible?)
    end

    def enabled_by_order_for_form(form_name)
      by_order.select { |fs| fs.visible? && fs.form.name == form_name } || []
    end

    def all_form_sections_for(form_name)
      all.select { |fs| !fs.form.nil? && fs.form.name == form_name }
    end

    def all_child_field_names
      all_child_fields.map { |field| field['name'] }
    end

    def all_visible_child_fields_for_form(form_name)
      enabled_by_order_for_form(form_name).map do |form_section|
        form_section.fields.select(&:visible?)
      end.flatten
    end

    def all_child_fields
      all.map do |form_section|
        form_section.fields
      end.flatten
    end

    def enabled_by_order_without_hidden_fields
      enabled_by_order.each do |form_section|
        form_section['fields'].map! { |field| field if field.visible? }
        form_section['fields'].compact!
      end
    end
  end

  def all_text_fields
    fields.select { |field| field.type == Field::TEXT_FIELD || field.type == Field::TEXT_AREA }
  end

  def all_searchable_fields
    fields.select { |field| field.type == Field::TEXT_FIELD || field.type == Field::TEXT_AREA || field.type == Field::SELECT_BOX }
  end

  def all_sortable_fields
    all_searchable_fields.select(&:visible?)
  end

  def self.all_sortable_field_names
    all.map { |form| form.all_sortable_fields.map(&:name) }.flatten
  end

  def self.get_by_unique_id(unique_id)
    by_unique_id(:key => unique_id).first
  end

  def self.add_field_to_form_section(form_section, field)
    fail I18n.t('errors.models.form_section.add_field_to_form_section') unless form_section.editable
    field.merge!('base_language' => form_section['base_language'])
    form_section.fields.push(field)
    form_section.save
  end

  def self.get_form_containing_field(field_name)
    all.find { |form| form.fields.find { |field| field.name == field_name || field.display_name == field_name } }
  end

  def self.new_with_order(form_section)
    form_section[:order] = by_order.last ? (by_order.last.order + 1) : 1
    FormSection.new(form_section)
  end

  def self.change_form_section_state(form_section, to_state)
    form_section.enabled = to_state
    form_section.save
  end

  def properties=(properties)
    properties.each_pair do |name, value|
      send("#{name}=", value) unless value.nil?
    end
  end

  def add_field(field)
    self['fields'] << Field.new(field)
  end

  def update_field_as_highlighted(field_name)
    field = fields.find { |f| f.name == field_name }
    existing_max_order = form.highlighted_fields.
        map(&:highlight_information).
        map(&:order).
        max
    order = existing_max_order.nil? ? 1 : existing_max_order + 1
    field.highlight_with_order order
    save
  end

  def remove_field_as_highlighted(field_name)
    field = fields.find { |f| f.name == field_name }
    field.unhighlight
    save
  end

  def section_name
    unique_id
  end

  def delete_field(field_to_delete)
    field = fields.find { |f| f.name == field_to_delete }
    fail I18n.t('errors.models.form_section.delete_field') unless field.editable?
    if field
      field_index = fields.index(field)
      fields.delete_at(field_index)
      save
    end
  end

  def field_order(field_name)
    field_item = fields.find { |field| field.name == field_name }
    fields.index(field_item)
  end

  def order_fields(new_field_names)
    new_fields = []
    new_field_names.each { |name| new_fields << fields.find { |field| field.name == name } }
    self.fields = new_fields
    save
  end

  def get_field_by_name(field_name)
    fields.select { |field| field.name == field_name }.first
  end

  def merge_fields!(fields_to_merge)
    current_field_names = fields.map(&:name)
    fields_to_merge.reject! { |field| current_field_names.include? field.name }
    fields_to_merge.each { |new_field| fields << new_field }
  end

  protected

  def validate_name_format
    special_characters = /[*!@#%$\^]/
    white_spaces = /^(\s+)$/
    if (name =~ special_characters) || (name =~ white_spaces)
      return errors.add(:name, I18n.t('errors.models.form_section.format_of_name'))
    else
      return true
    end
  end

  def validate_visible_field
    self.visible = true if self.perm_visible?
    if self.perm_visible? && visible == false
      errors.add(:visible, I18n.t('errors.models.form_section.visible_method'))
    end
    true
  end

  def validate_fixed_order
    self.fixed_order = true if self.perm_enabled?
    if self.perm_enabled? && fixed_order == false
      errors.add(:fixed_order, I18n.t('errors.models.form_section.fixed_order_method'))
    end
    true
  end

  def validate_perm_visible
    self.perm_visible = true if self.perm_enabled?
    if self.perm_enabled? && perm_visible == false
      errors.add(:perm_visible, I18n.t('errors.models.form_section.perm_visible_method'))
    end
    true
  end

  def validate_unique_id
    form_section = FormSection.get_by_unique_id(unique_id)
    unique = form_section.nil? || form_section.id == id
    unique || errors.add(:unique_id, I18n.t('errors.models.form_section.unique_id', :unique_id => unique_id))
  end

  def validate_unique_name
    unique = FormSection.all.select { |fs| fs.form == form } .all? { |fs| id == fs.id || name.nil? || name.empty? || name != fs.name }
    unique || errors.add(:name, I18n.t('errors.models.form_section.unique_name', :name => name))
  end

  def create_unique_id
    self.unique_id = UUIDTools::UUID.random_create.to_s.split('-').first if unique_id.nil?
  end

  private

  # Flag saved CastedBy fields (:document_saved to true) in order to be aware
  # that items were saved or they were loaded from the database.
  # TODO: move to a monkey patch for CouchRest::Model::Base
  def flag_saved_embedded_properties
    casted_properties = properties_with_values.select { |_property, value| value.respond_to?(:casted_by) && value.respond_to?(:casted_by_property) }
    casted_properties.each do |_property, value|
      if value.instance_of?(CouchRest::Model::CastedArray)
        value.each do |item|
          item.document_saved = true if item.respond_to?(:document_saved)
        end
      elsif value.instance_of?(CouchRest::Model::CastedHash) && value.respond_to?(:document_saved)
        value.document_saved = true
      end
    end
  end
end
