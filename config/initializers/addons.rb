# Enable necessary addons

Addons::PhotowallExportTask.enable
Addons::PdfExportTask.enable
Addons::CsvExportTask.enable
RapidftrAddonCpims::ExportTask.enable

RapidftrAddon::ExportTask.implementations.each do |impl|
  Mime::Type.register 'application/zip', impl.addon_id
end
