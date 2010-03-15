require "prawn/measurement_extensions"
require 'prawn/layout'

class PdfGenerator
  def initialize
    @pdf = Prawn::Document.new
    @image_bounds = [@pdf.bounds.width,@pdf.bounds.width]
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

  private

  def add_child_page(child)
    @pdf.image( 
      StringIO.new( child.photo ), 
      :position => :center,
      :vposition => :top,
      :fit => @image_bounds 
    )
    @pdf.y -= 5.mm
    @pdf.text( 
      child.unique_identifier,
      :align => :center
    )
  end
end
