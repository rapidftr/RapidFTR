Role.all.each do |role|
  next unless role.has_permission('Export to Photowall/CSV/PDF')
  role.permissions += [Permission::CHILDREN[:export_photowall], Permission::CHILDREN[:export_csv],
                       Permission::CHILDREN[:export_pdf]]
  role.permissions -= ['Export to Photowall/CSV/PDF']
  role.save
end
