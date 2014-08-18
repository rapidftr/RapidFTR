# Enable necessary addons

RapidftrAddon::ExportTask.options = {:tmp_dir => CleansingTmpDir.dir}

Addons::PhotowallExportTask.enable
Addons::PdfExportTask.enable
Addons::CsvExportTask.enable
RapidftrAddonCpims::ExportTask.enable

RapidftrAddon::ExportTask.active.each do |impl|
  Mime::Type.register 'application/zip', impl.id
end
