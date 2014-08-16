module Addons
  class PdfExportTask < RapidftrAddon::ExportTask

    def self.id
      :pdf
    end

    def export(children)
      [Result.new(generate_filename(children), generate_data(children))]
    end

    def generate_data(children)
      ExportGenerator.new(children).to_full_pdf
    end

    def generate_filename(children)
      ((children && children.length == 1) ? (children[0]['unique_identifier']) : 'full_data') + '.pdf'
    end

  end
end
