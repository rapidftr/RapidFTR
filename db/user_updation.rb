field_worker = User.find_by_user_name("limited")
if field_worker
  role = Role.new(:name => "field worker", :permissions => [Permission::REGISTER_CHILD]).save!
  field_worker.user_name = "field_worker"
  field_worker.role_names = [role.name]
  field_worker.save!
end

field_admin = User.find_by_user_name("unlimited")
if field_admin
  role = Role.new(:name => "field admin", :permissions => [Permission::ACCESS_ALL_DATA]).save!
  field_admin.user_name = "field_admin"
  field_admin.role_names = [role.name]
  field_admin.save!
end