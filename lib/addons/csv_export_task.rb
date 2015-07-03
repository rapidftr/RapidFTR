module Addons
  class CsvExportTask < RapidftrAddon::ExportTask
    def self.id
      :csv
    end

    def export(models)
      [Result.new(generate_filename(models), generate_data(models))]
    end

    def generate_data(models)
      ExportGenerator.new(models).to_csv.data
    end

    def generate_filename(models)
      ((models && models.length == 1) ? (models[0]['unique_identifier']) : 'full_data') + '.csv'
    end
  end
end
