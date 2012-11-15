class FormSection < CouchRestRails::Document
  include CouchRest::Validation
  include RapidFTR::Model

  use_database :form_section
  property :unique_id
  property :name
  property :description
  property :help_text
  property :enabled, :cast_as => 'boolean', :default => true
  property :order, :type      => Integer
  property :fields, :cast_as => ['Field']
  property :editable, :cast_as => 'boolean', :default => true
  property :perm_enabled, :cast_as => 'boolean', :default => false
  property :validations, :type => [String]

  view_by :unique_id
  view_by :order

  validates_presence_of :name
  validates_format_of :name, :with =>/^([a-zA-Z0-9_\s]*)$/, :message=>"Name must contain only alphanumeric characters and spaces"
  validates_with_method :unique_id, :method => :validate_unique_id
  validates_with_method :name, :method => :validate_unique_name

  def initialize args={}
    self["fields"] = []
    create_unique_id
    super args
  end

  alias to_param unique_id

  class << self
    def enabled_by_order
      by_order.select(&:enabled?)
    end

    def all_child_field_names
      all_child_fields.map{ |field| field["name"] }
    end

    def all_enabled_child_fields
      enabled_by_order.map do |form_section|
        form_section.fields.find_all(&:enabled)
      end.flatten
    end

    def all_child_fields
      all.map do |form_section|
        form_section.fields
      end.flatten
    end

    def enabled_by_order_without_disabled_fields
      enabled_by_order.each do |form_section|
        form_section['fields'].map! { |field| field if field.enabled }
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
    raise "Form section not editable" unless formsection.editable
    formsection.fields.push(field)
    formsection.save
  end

  def self.get_form_containing_field field_name
    all.find { |form| form.fields.find { |field| field.name == field_name || field.display_name == field_name } }
  end

  def self.create_new_custom name, description = "", help_text = "", enabled=true
    max_order= (all.map{|form_section| form_section.order}).max || 0
    form_section = FormSection.new :name=>name,
                                   :description=>description,
                                   :help_text=>help_text,
                                   :enabled=>enabled,
                                   :order=>max_order+1
    form_section = create! form_section if form_section.valid?
    form_section
  end

  def self.change_form_section_state formsection, to_state
    formsection.enabled = to_state
    formsection.save
  end

  def properties= properties
    properties.each_pair do |name, value|
      self[name] = value unless value == nil
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
    raise "Uneditable field cannot be deleted" if !field.editable?
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

  def move_field field_to_move, offset
    raise "Uneditable field cannot be moved" if !field_to_move.editable?
    field_index_1 = fields.index(field_to_move)
    field_index_2 = field_index_1 + offset
    raise "Out of range!" if field_index_2 < 0 || field_index_2 >= fields.length
    fields[field_index_1], fields[field_index_2] = fields[field_index_2], fields[field_index_1]
    save()
  end

  def move_up_field field_name
    field_to_move_up = fields.find {|field| field.name == field_name}
    move_field(field_to_move_up, - 1)
  end

  def move_down_field field_name
    field_to_move_down = fields.find {|field| field.name == field_name}
    move_field(field_to_move_down, 1)
  end

  def disable_fields fields_to_disable
    matching_fields = fields.select { |field| fields_to_disable.include? field.name }
    matching_fields.each{ |field| field.enabled = false }
  end

  def enable_fields fields_to_enable
    matching_fields = fields.select { |field| fields_to_enable.include? field.name }
    matching_fields.each{ |field| field.enabled = true}
  end

  protected

  def validate_unique_id
    form_section = FormSection.get_by_unique_id(self.unique_id)
    unique = form_section.nil? || form_section.id == self.id
    unique || [false, "The unique id '#{unique_id}' is already taken."]
  end

  def validate_unique_name
    unique = FormSection.all.all? {|f| id == f.id || name != nil && name != f.name }
    unique || [false, "The name '#{name}' is already taken."]
  end

  def create_unique_id
    self.unique_id = UUIDTools::UUID.timestamp_create.to_s.split('-').first if self.unique_id.nil?
  end
end
