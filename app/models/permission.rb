class Permission

  def self.to_ordered_hash *hashes
    ordered = ActiveSupport::OrderedHash.new

    hashes.each do |hash|
      hash.each {|key, value| ordered[key] = value}
    end
    ordered
  end

  CHILDREN = Permission.to_ordered_hash({:register => "Register Child"}, {:edit => "Edit Child"},
                                         {:view_and_search => "View And Search Child"}, {:export => "Export to Photowall/CSV/PDF"})
  FORMS    = Permission.to_ordered_hash({:manage => "Manage Forms"})
  USERS    = Permission.to_ordered_hash({:create_and_edit => "Create and Edit Users"},{:view => "View Users"},
                                         {:destroy => "Delete Users"},{:disable => "Disable Users"})
  DEVICES  = Permission.to_ordered_hash({:black_list => "BlackList Devices"})
  REPORTS  = Permission.to_ordered_hash({})
  ROLES    = Permission.to_ordered_hash({:create_and_edit => "Create and Edit Roles"},{:view => "View roles"})
  SYSTEM   = Permission.to_ordered_hash({ :settings => "System Settings",
                                          :highlight_fields => "Highlight Fields" })

  def self.all
    { "Children" => CHILDREN, "Forms" => FORMS, "Users" => USERS, "Devices" => DEVICES, "Reports" => REPORTS, "Roles" => ROLES, "System" => SYSTEM }
  end

  def self.all_permissions
    self.all.values.map(&:values).flatten
  end

  def self.hashed_values
    {"ALL" =>["All"], "Admin" => ADMIN.values, "Children" => CHILDREN.values, "Forms" => FORMS.values, "Users" => USERS.values, "Devices" => DEVICES.values, "Reports" => REPORTS.values, "Roles" => ROLES.values, "System" => SYSTEM.values }
  end

end
