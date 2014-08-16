module Addons
  class PhotowallExportTask < RapidftrAddon::ExportTask

    def self.id
      :photowall
    end

    def export(children)
      [Result.new(generate_filename(children), generate_data(children))]
    end

    def generate_data(children)
      ExportGenerator.new(children).to_photowall_pdf
    end

    def generate_filename(children)
      ((children && children.length == 1) ? (children[0]['unique_identifier']) : 'photowall') + '.pdf'
    end

  end
end
