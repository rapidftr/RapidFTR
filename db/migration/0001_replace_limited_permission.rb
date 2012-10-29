field_worker = User.find_by_user_name("limited")
if field_worker
  role = Role.find_by_name("Field Worker") || Role.create(:name => "field worker", :permissions => [Permission::CHILDREN[:register]])
  field_worker.user_name = "field_worker"
  field_worker.role_names = [role.name]
  field_worker.save!
end

field_admin = User.find_by_user_name("unlimited")
if field_admin
  role = Role.find_by_name("Field Admin") || Role.create(:name => "field admin", :permissions => [Permission::CHILDREN[:access_all_data]])
  field_admin.user_name = "field_admin"
  field_admin.role_names = [role.name]
  field_admin.save!
end

role = Role.find_by_name("Admin")
role.update_attributes(:permissions => [Permission::ADMIN[:admin]]) if role