require "prawn/measurement_extensions"
require 'prawn/layout'
include ActionController::UrlWriter

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

	def to_csv path
		fields = FormSection.all_enabled_child_fields
		fields.unshift Field.new_text_field("unique_identifier")
		field_names = fields.map{|field| field.name}
		csv_data = FasterCSV.generate do |rows|
			rows << field_names
			@child_data.each do |child|
				rows << fields.map { |field| format_field_for_export(field, child[field.name], child.unique_identifier, path) }
			end
		end

		return Export.new csv_data, {:type=>'text/csv', :filename=>filename("full-details", "csv")} 
	end

	def to_full_pdf
		@child_data.each do |child|
			add_child_page(child)
			@pdf.start_new_page unless @child_data.last == child
		end
		@pdf.render
	end

	private
	def format_field_for_export field, value, child_id, path
		if (field.type ==  Field::CHECK_BOXES) 
			return value.join(", ") unless value.nil?
		end
          if field.name != nil then
            if value != nil then        
              if field.name.index('photo') != nil then
                return path + child_photo_path(child_id)
              end
              if field.name.index('audio') != nil then
                return path + child_audio_path(child_id)
              end
            end
          end
          return value || ""
	end

	def filename export_type, extension
		return "rapidftr-#{@child_data[0][:unique_identifier]}-#{filename_date_string}.#{extension}" if @child_data.length == 1
		return "rapidftr-#{export_type}-#{filename_date_string}.#{extension}"
	end

	def filename_date_string
		Clock.now.strftime("%Y%m%d")
	end

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
				select { |field| field.type != Field::PHOTO_UPLOAD_BOX && field.type != Field::AUDIO_UPLOAD_BOX && field.enabled? }.
				map { |field| [field.display_name, format_field_for_export(field, child[field.name], child.unique_identifier)] }
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
