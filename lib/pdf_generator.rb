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
    all_children_but_last = children.slice(0,children.length-1)
    all_children_but_last.each do |child|
      add_child_page(child)
      @pdf.start_new_page
    end
    add_child_page(children.last)

    @pdf.render
  end


  def child_info(child)
    add_child_page(child)
    @pdf.render
  end

  private
  def add_child_page(child)
    @pdf.image( 
      child.photo.data, 
      :position => :center,
      :vposition => :top,
      :fit => @image_bounds 
    ) if child.photo
    @pdf.y -= 5.mm
    @pdf.text( 
      child.unique_identifier,
      :align => :center
    )
    FormSection.all_by_order {|section| section.enabled? }.each do |section|

      @pdf.text section.section_name.humanize.capitalize, :style => :bold, :size => 16

      @pdf.table section.fields.
              select { |field| field.type != Field::PHOTO_UPLOAD_BOX && field.type != Field::AUDIO_UPLOAD_BOX }.
              map { |field| [field.display_name.humanize, child[field.name]] },
                 :border_width => 0, :row_colors => %w[ cccccc ffffff ],
                 :width => 500, :column_widths => {0 => 200, 1 => 300},
                 :position => :left
      @pdf.move_down 10
    end
  end
end
