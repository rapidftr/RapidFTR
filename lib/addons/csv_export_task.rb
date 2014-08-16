module Addons
  class CsvExportTask < RapidftrAddon::ExportTask

    def self.id
      :csv
    end

    def export(children)
      [Result.new(generate_filename(children), generate_data(children))]
    end

    def generate_data(children)
      ExportGenerator.new(children).to_csv.data
    end

    def generate_filename(children)
      ((children && children.length == 1) ? (children[0]['unique_identifier']) : 'full_data') + '.csv'
    end

  end
end
