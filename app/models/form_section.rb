class FormSection < CouchRestRails::Document
  include CouchRest::Validation
  use_database :form_section
  property :unique_id
  property :name
  property :description
  property :enabled, :cast_as => 'boolean'
  property :order, :type      => Integer
  property :fields, :cast_as => ['Field']
  property :editable, :cast_as => 'boolean', :default => true

  view_by :unique_id
  view_by :order

  def self.all_by_order
    view 'by_order'
  end

  validates_presence_of :name
  validates_format_of :name, :with =>/^([a-zA-Z0-9_\s]*)$/, :message=>"Name must contain only alphanumeric characters and spaces"

  def initialize args={}
    self["fields"] = []
    super args
  end 

  def self.all_child_field_names
    all_child_fields.map{ |field| field["name"] }
  end

  def self.all_child_fields
    all.map do |form_section|
      form_section.fields
    end.flatten
  end

  def self.get_by_unique_id unique_id
    by_unique_id(:key => unique_id).first
  end

  def self.add_field_to_formsection formsection, field
    raise "Field already exists for this form section" if formsection.has_field(field.name)
    raise "Form section not editable" unless formsection.editable
    formsection.fields.push(field)
    formsection.save
  end
  
  def self.create_new_custom name, description = "", enabled=true
    unique_id = (name||"").gsub(/\s/, "_").downcase
    max_order= (all.map{|form_section| form_section.order}).max || 0
    form_section = FormSection.new :unique_id=>unique_id, :name=>name, :description=>description, :enabled=>enabled, :order=>max_order+1
    name1 =  form_section.name
    form_section = create! form_section if form_section.valid?
    form_section
  end

  def self.change_form_section_state formsection, to_state
    formsection.enabled = to_state
    formsection.save
  end
  
  def add_text_field field_name
    self["fields"] << Field.new_text_field(field_name)
  end

  def add_field field
    self["fields"] << Field.new(field)
  end

  def has_field field_name
    fields.find {|field| field.name == field_name} != nil
  end

  def section_name
    unique_id
  end
  
  def delete_field field_to_delete
    field = fields.find {|field| field.name == field_to_delete}
    if (field)
      field_index = fields.index(field)
      fields.delete_at(field_index)
      save()
    end
  end
  
  def move_field field_to_move, offset
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
end
