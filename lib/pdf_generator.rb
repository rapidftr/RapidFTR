require "prawn/measurement_extensions"
require 'prawn/layout'

class PdfGenerator
  def child_photo(child)
    pdf = Prawn::Document.new
    image_bounds = [pdf.bounds.width,pdf.bounds.width]
    pdf.image( 
      StringIO.new( child.photo ), 
      :position => :center,
      :vposition => :top,
      :fit => image_bounds 
    )
    pdf.y -= 5.mm
    pdf.text( 
      child.unique_identifier,
      :align => :center
    )
    pdf.render
  end
end
