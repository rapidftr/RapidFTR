require "prawn/measurement_extensions"
require 'prawn/layout'

class PdfGenerator
  def initialize
    @pdf = Prawn::Document.new
    @image_bounds = [@pdf.bounds.width,@pdf.bounds.width]
  end

  def child_photo(child)
    child_photos( [child] )
  end

  def child_photos(children)
    children.each do |child|
      add_child_photo(child)
      @pdf.start_new_page unless children.last == child
    end
    @pdf.render
  end


  def child_info(child)
    add_child_page(child)
    @pdf.render
  end

  def children_info(children)
    children.each do |child|
      add_child_page(child)
      @pdf.start_new_page unless children.last == child
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
