require 'csv'
require 'prawn/measurement_extensions'
require 'prawn/layout'

CHILD_IDENTIFIERS = ["unique_identifier", "short_id"]
CHILD_METADATA = ["created_by", "created_organisation", "posted_at", "last_updated_by_full_name", "last_updated_at"]
CHILD_STATUS = ["Suspect status", "Reunited status"]

class ExportGenerator
  class Export
    attr_accessor :data, :options

    def initialize(data, options)
      @data = data
      @options = options
    end
  end

  def initialize(*child_data)
    @child_data = child_data.flatten
    @pdf = Prawn::Document.new
    @image_bounds = [@pdf.bounds.width, @pdf.bounds.width]
  end

  def to_photowall_pdf
    @child_data.each do |child|
      begin
        add_child_photo(child, true)
        @pdf.start_new_page unless @child_data.last == child
      rescue => e
        Rails.logger.error e
      end
    end
    @pdf.render
  end

  def to_csv
    fields = metadata_fields([], CHILD_IDENTIFIERS) + FormSection.all_visible_child_fields_for_form(Child::FORM_NAME)
    field_names = fields.map { |field| field.display_name }
    csv_data = CSV.generate do |rows|
      rows << field_names + CHILD_STATUS + metadata_fields([], CHILD_METADATA).map { |field| field.display_name }
      @child_data.each do |child|
        begin
          child_data = map_field_with_value(child, fields)
          child_data << (child.flag? ? "Suspect" : "")
          child_data << (child.reunited? ? "Reunited" : "")
          metadata = metadata_fields([], CHILD_METADATA)
          metadata_value = map_field_with_value(child, metadata)
          child_data += metadata_value
          rows << child_data
        rescue => e
          Rails.logger.error e
        end
      end
    end

    return Export.new csv_data, {:type => 'text/csv', :filename => filename("full-details", "csv")}
  end

  def map_field_with_value(child, fields)
    fields.map { |field| format_field_for_export(field, child[field.name] || child.send(field.name), child) }
  end

  def metadata_fields(fields, extras)
    extras.each do |extra|
      fields.push Field.new(:name => extra, :display_name => extra.humanize)
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

  def format_field_for_export(field, value, child = nil)
    return "" if value.blank?
    return value.join(", ") if field.type == Field::CHECK_BOXES
    if child
      # TODO:
      # child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless (child.primary_photo_id.nil? || child.primary_photo_id == "")
      # child['audio_url'] = child_audio_url(child)

      return child['photo_url'] if field.name.include?('photo')
      return child['audio_url'] if field.name.include?('audio')
    end
    value
  end

  def filename(export_type, extension)
    return "rapidftr-#{@child_data[0][:unique_identifier]}-#{filename_date_string}.#{extension}" if @child_data.length == 1
    return "rapidftr-#{export_type}-#{filename_date_string}.#{extension}"
  end

  def filename_date_string
    Clock.now.strftime("%Y%m%d")
  end

  def add_child_photo(child, with_full_id = false)
    if child.primary_photo
      render_image(child.primary_photo.data)
    else
      @@no_photo_clip = File.binread("app/assets/images/no_photo_clip.jpg")
      @attachment = FileAttachment.new("no_photo", "image/jpg", @@no_photo_clip)
      render_image(@attachment.data)
    end
    @pdf.move_down 25
    @pdf.text child.short_id, :size => 40, :align => :center, :style => :bold if with_full_id

    @pdf.y -= 3.mm
  end

  def render_image(data)
    @pdf.image(
        data,
        :position => :center,
        :vposition => :top,
        :fit => @image_bounds
    )
  end

  def add_child_details(child)
    flag_if_suspected(child)
    flag_if_reunited(child)
    @fields ||= metadata_fields([], CHILD_IDENTIFIERS + CHILD_METADATA)
    field_pair = @fields.map { |field| [field.display_name, format_field_for_export(field, child[field.name])] }
    render_pdf(field_pair)
    @form_sections ||= FormSection.enabled_by_order
    @form_sections.each do |section|
      @pdf.text section.name, :style => :bold, :size => 16
      field_pair = section.fields.
          select { |field| field.type != Field::PHOTO_UPLOAD_BOX && field.type != Field::AUDIO_UPLOAD_BOX && field.visible? }.
          map { |field| [field.display_name, format_field_for_export(field, child[field.name])] }
      render_pdf(field_pair)
    end
  end

  def render_pdf(field_pair)
    unless field_pair.empty?
      @pdf.table field_pair,
                 :border_width => 0, :row_colors => %w[  cccccc ffffff  ],
                 :width => 500, :column_widths => {0 => 200, 1 => 300},
                 :position => :left
    end
    @pdf.move_down 10
  end

  def add_child_page(child)
    add_child_photo(child)
    add_child_details(child)
  end

  def flag_if_suspected(child)
    @pdf.text("Flagged as Suspect Record", :style => :bold) if child.flag?
  end

  def flag_if_reunited(child)
    @pdf.text("Reunited", :style => :bold) if child.reunited?
  end
end
