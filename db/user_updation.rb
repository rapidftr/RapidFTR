field_worker = User.find_by_user_name("limited")
if field_worker
  role = Role.new(:name => "field_worker", :permissions => [Permission::REGISTER_CHILD, Permission::EDIT_CHILD]).save!
  field_worker.role_names = [role.name]
  field_worker.save!
end
