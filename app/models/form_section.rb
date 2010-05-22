class FormSection < CouchRestRails::Document
  use_database :form_section
  
  property :unique_id
  property :name
  property :description
  property :enabled, :cast_as => 'boolean'
  property :order
  property :fields, :cast_as => ['Field']
  property :editable, :cast_as => 'boolean', :default => true

  view_by :unique_id

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
