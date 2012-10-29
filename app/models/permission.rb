class Permission
  
  ADMIN = {:admin => "Admin"}
  CHILDREN = {:register => "Register Child", :edit => "Edit Child", :access_all_data => "Access all data"}
  FORMS = {}
  USERS = {:create_and_edit => "Create and Edit Users", :view => "View Users"}
  DEVICES = {}
  REPORTS = {}

  def self.all
    {"Admin" => ADMIN, "Children" => CHILDREN, "Forms" => FORMS, "Users" => USERS, "Devices" => DEVICES, "Reports" => REPORTS}
  end

end
