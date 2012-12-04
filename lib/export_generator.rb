require "prawn/measurement_extensions"
require 'prawn/layout'

CHILD_IDENTIFIERS = ["unique_identifier", "short_id"]
CHILD_METADATA = ["created_by", "created_organisation", "posted_at", "last_updated_by_full_name", "last_updated_at"]

class ExportGenerator
  class Export
    attr_accessor :data, :options
    def initialize data, options
      @data = data
      @options = options
    end
  end
  def initialize *child_data
    @child_data = child_data.flatten 
    @pdf = Prawn::Document.new
    @image_bounds = [@pdf.bounds.width,@pdf.bounds.width]
  end

  def to_photowall_pdf
    @child_data.each do |child|
      add_child_photo(child)
      @pdf.start_new_page unless @child_data.last == child
    end
    @pdf.render
  end

  def to_csv
    fields = metadata_fields([],CHILD_IDENTIFIERS) + FormSection.all_enabled_child_fields
    fields = metadata_fields(fields , CHILD_METADATA)
    field_names = fields.map {|field| field.name}
    csv_data = FasterCSV.generate do |rows|
      rows << field_names + ["Suspect Status", "Reunited Status"]
      @child_data.each do |child|
        child_data = fields.map { |field| format_field_for_export(field, child[field.name] || child.send(field.name), child) }
        child_data << (child.flag? ? "Suspect" : nil)
        child_data << (child.reunited? ? "Reunited" : nil)
        rows << child_data
      end
    end

    return Export.new csv_data, {:type=>'text/csv', :filename=>filename("full-details", "csv")} 
  end

  def metadata_fields(fields,extras)
    extras.each do |extra|
      fields.push Field.new_text_field(extra)
    end
    fields
  end

  def to_full_pdf
    @child_data.each do |child|
      add_child_page(child)
      @pdf.start_new_page unless @child_data.last == child
    end
    @pdf.render
  end

  private
  
  def format_field_for_export field, value, child=nil
    return "" if value.blank?
    return value.join(", ") if field.type ==  Field::CHECK_BOXES
    if child
      return child['photo_url'] if field.name.include?('photo')
      return child['audio_url'] if field.name.include?('audio')
    end
    value
  end

  def filename export_type, extension
    return "rapidftr-#{@child_data[0][:unique_identifier]}-#{filename_date_string}.#{extension}" if @child_data.length == 1
    return "rapidftr-#{export_type}-#{filename_date_string}.#{extension}"
  end

  def filename_date_string
    Clock.now.strftime("%Y%m%d")
  end

  def add_child_photo(child, with_full_id = false)
    @pdf.image(
      child.primary_photo.data,
      :position => :center,
      :vposition => :top,
      :fit => @image_bounds
    ) if child.primary_photo

    if with_full_id
      @pdf.y -= 5.mm
      @pdf.text child.unique_identifier, :align => :center
    end 

    @pdf.y -= 5.mm
    @pdf.text child.short_id, :align => :center
  end

  def add_child_details(child)
    flag_if_suspected(child)
    flag_if_reunited(child)
    fields = metadata_fields([], CHILD_METADATA)
    field_pair = fields.map { |field| [field.display_name, format_field_for_export(field, child[field.name])] }
    render_pdf(field_pair)
    FormSection.enabled_by_order.each do |section|
      @pdf.text section.name, :style => :bold, :size => 16
      field_pair = section.fields.
        select { |field| field.type != Field::PHOTO_UPLOAD_BOX && field.type != Field::AUDIO_UPLOAD_BOX && field.enabled? }.
        map { |field| [field.display_name, format_field_for_export(field, child[field.name])] }
      render_pdf(field_pair)
    end
  end

  def render_pdf(field_pair)
    if !field_pair.empty?
      @pdf.table field_pair,
                 :border_width => 0, :row_colors => %w[  cccccc ffffff  ],
                 :width => 500, :column_widths => {0 => 200, 1 => 300},
                 :position => :left
    end
    @pdf.move_down 10
  end

  def add_child_page(child)
    add_child_photo(child, true)
    add_child_details(child)
  end

  def flag_if_suspected(child)
    @pdf.text("Flagged as Suspect Record", :style => :bold) if child.flag?
  end

  def flag_if_reunited(child)
    @pdf.text("Reunited", :style => :bold) if child.reunited?
  end
end
