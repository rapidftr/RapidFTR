require "prawn/measurement_extensions"
require 'prawn/layout'

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
    field_names = FormSection.all_enabled_child_fields.map {|field| field.name}
    field_names.unshift "unique_identifier"
    field_names 
		csv_data = FasterCSV.generate do |rows|
      rows << field_names
      @child_data.each do |child|
          rows << field_names.map { |field_name| child[field_name] }
      end
    end

		return Export.new csv_data, {:type=>'text/csv', :filename=>filename("full-details", "csv")} 
	end
  
	def filename export_type, extension
		return "rapidftr-#{export_type}-#{filename_date_string}.#{extension}"
	end

	def filename_date_string
    Clock.now.strftime("%Y%m%d")
  end

 	def to_full_pdf
    @child_data.each do |child|
      add_child_page(child)
      @pdf.start_new_page unless @child_data.last == child
    end
    @pdf.render
  end

  private
  def add_child_photo(child)
    @pdf.image(
            child.primary_photo.data,
            :position => :center,
            :vposition => :top,
            :fit => @image_bounds
    ) if child.primary_photo
    @pdf.y -= 5.mm
    @pdf.text(
            child.unique_identifier,
            :align => :center
    )
  end

  def add_child_details(child)
    FormSection.enabled_by_order.each do |section|
      @pdf.text section.name, :style => :bold, :size => 16
      field_pair = section.fields.
              select { |field| field.type != Field::PHOTO_UPLOAD_BOX && field.type != Field::AUDIO_UPLOAD_BOX }.
              map { |field| [field.display_name, child[field.name]] }
      if !field_pair.empty?
        @pdf.table field_pair,
           :border_width => 0, :row_colors => %w[  cccccc ffffff  ],
           :width => 500, :column_widths => {0 => 200, 1 => 300},
           :position => :left
      end
      @pdf.move_down 10
    end
  end

  def add_child_page(child)
    add_child_photo(child)
    add_child_details(child)
  end
end
