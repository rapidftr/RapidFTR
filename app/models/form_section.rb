class FormSection < CouchRestRails::Document
  include CouchRest::Validation
  include RapidFTR::Model
  include PropertiesLocalization

  use_database :form_section
  PropertiesLocalization.localize_properties [:name, :help_text, :description]
  property :unique_id
  property :visible, :cast_as => 'boolean', :default => true
  property :order, :type      => Integer
  property :fields, :cast_as => ['Field']
  property :editable, :cast_as => 'boolean', :default => true
  property :fixed_order, :cast_as => 'boolean', :default => false
  property :perm_visible, :cast_as => 'boolean', :default => false
  property :perm_enabled, :cast_as => 'boolean'
  property :validations, :type => [String]

  view_by :unique_id
  view_by :order

  validates_presence_of "name_#{I18n.default_locale}", :message=> I18n.t("models.form_section.validation.error_message.presence_of_name")
  validates_format_of :name, :with =>/^([a-zA-Z0-9_\s]*)$/, :message=> I18n.t("models.form_section.validation.error_message.format_of_name")
  validates_with_method :unique_id, :method => :validate_unique_id
  validates_with_method :name, :method => :validate_unique_name
  validates_with_method :visible, :method => :validate_visible_field, :message=> I18n.t("models.form_section.validation.error_message.visible_method")
  validates_with_method :fixed_order, :method => :validate_fixed_order, :message=> I18n.t("models.form_section.validation.error_message.fixed_order_method")
  validates_with_method :perm_visible, :method => :validate_perm_visible, :message=> I18n.t("models.form_section.validation.error_message.perm_visible_method")

  def initialize args={}
    self["fields"] = []
    super args
    create_unique_id
  end

  alias to_param unique_id

  class << self
    def enabled_by_order
      by_order.select(&:visible?)
    end

    def all_child_field_names
      all_child_fields.map{ |field| field["name"] }
    end

    def all_visible_child_fields
      enabled_by_order.map do |form_section|
        form_section.fields.find_all(&:visible)
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
    self.fields.select {|field| field.type == Field::TEXT_FIELD || field.type == Field::TEXT_AREA}
  end

  def all_searchable_fields
    self.fields.select {|field| field.type == Field::TEXT_FIELD || field.type == Field::TEXT_AREA || field.type == Field::SELECT_BOX }
  end

  def self.get_by_unique_id unique_id
    by_unique_id(:key => unique_id).first
  end

  def self.add_field_to_formsection formsection, field
    raise I18n.t("models.form_section.validation.error_message.add_field_to_form_section") unless formsection.editable
    formsection.fields.push(field)
    formsection.save
  end

  def self.get_form_containing_field field_name
    all.find { |form| form.fields.find { |field| field.name == field_name || field.display_name == field_name } }
  end

  def self.new_with_order form_section
    form_section[:order] = by_order.last ? (by_order.last.order + 1) : 1
    FormSection.new(form_section)
  end

  def self.change_form_section_state formsection, to_state
    formsection.enabled = to_state
    formsection.save
  end

  def properties= properties
    properties.each_pair do |name, value|
      self.send("#{name}=", value) unless value == nil
    end
  end

  def add_text_field field_name
    self["fields"] << Field.new_text_field(field_name)
  end

  def add_field field
    self["fields"] << Field.new(field)
  end

  def update_field_as_highlighted field_name
    field = fields.find {|field| field.name == field_name }
    existing_max_order = FormSection.highlighted_fields.
                                     map(&:highlight_information).
                                     map(&:order).
                                     max
    order = existing_max_order.nil? ? 1 : existing_max_order + 1
    field.highlight_with_order order
    save
  end

  def remove_field_as_highlighted field_name
    field = fields.find {|field| field.name == field_name }
    field.unhighlight
    save
  end

  def self.highlighted_fields
    all.map do |form|
      form.fields.select{ |field| field.is_highlighted? }
    end.flatten
  end

  def self.sorted_highlighted_fields
    highlighted_fields.sort{ |field1, field2| field1.highlight_information.order.to_i <=> field2.highlight_information.order.to_i }
  end

  def section_name
    unique_id
  end

  def is_first field_to_check
    field_to_check == fields.at(0)
  end

  def is_last field_to_check
    field_to_check == fields.at(fields.length-1)
  end

  def delete_field field_to_delete
    field = fields.find {|field| field.name == field_to_delete}
    raise I18n.t("models.form_section.validation.error_message.delete_field") if !field.editable?
    if (field)
      field_index = fields.index(field)
      fields.delete_at(field_index)
      save()
    end
  end

  def field_order field_name
    field_item = fields.find {|field| field.name == field_name}
    return fields.index(field_item)
  end

  def order_fields new_field_names
    new_fields = []
    new_field_names.each{ |name| new_fields << fields.find{|field| field.name == name} }
    self.fields = new_fields
    self.save
  end

  protected

  def validate_visible_field
    self.visible = true if self.perm_visible?
    true
  end

  def validate_fixed_order
    self.fixed_order = true if self.perm_enabled?
    true
  end

  def validate_perm_visible
    self.perm_visible = true if self.perm_enabled?
    true
  end

  def validate_unique_id
    form_section = FormSection.get_by_unique_id(self.unique_id)
    unique = form_section.nil? || form_section.id == self.id
    unique || [false, I18n.t("models.form_section.validation.error_message.unique_id", :unique_id => unique_id)]
  end

  def validate_unique_name
    unique = FormSection.all.all? {|f| id == f.id || name != nil && name != f.name }
    unique || [false, I18n.t("models.form_section.validation.error_message.unique_name", :name => name)]
  end

  def create_unique_id
    self.unique_id = UUIDTools::UUID.timestamp_create.to_s.split('-').first if self.unique_id.nil?
  end
end
