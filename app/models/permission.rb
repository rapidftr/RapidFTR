class Permission

  def self.to_ordered_hash2 *hashes
    ordered = ActiveSupport::OrderedHash.new

    hashes.each do |hash|
      hash.each {|key, value| ordered[key] = value}
    end
    ordered
  end

  ADMIN    = Permission.to_ordered_hash2({:admin, "Admin"})
  CHILDREN = Permission.to_ordered_hash2({:register => "Register Child"}, {:edit => "Edit Child"},
                                         {:view_and_search => "View And Search Child"}, {:export => "Export to Photowall/CSV/PDF"})
  FORMS    = Permission.to_ordered_hash2({})
  USERS    = Permission.to_ordered_hash2({:create_and_edit => "Create and Edit Users"},{:view => "View Users"},{:destroy => "Delete Users"},{:disable => "Disable Users"})
  DEVICES  = Permission.to_ordered_hash2({:black_list => "BlackList Devices"})
  REPORTS  = Permission.to_ordered_hash2({})

  def self.all
    {"Admin" => ADMIN, "Children" => CHILDREN, "Forms" => FORMS, "Users" => USERS, "Devices" => DEVICES, "Reports" => REPORTS}
  end

end
