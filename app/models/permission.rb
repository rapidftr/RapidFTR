class Permission

  ADMIN = "admin"
  LIMITED = "limited"
  ACCESS_ALL_DATA = "Access all data"
  REGISTER_CHILD = "Register Child"
  EDIT_CHILD = "Edit Child"
  CREATE_EDIT_USERS = "Create and Edit Users"
  VIEW_USERS = "View Users"

  def self.all
    [ADMIN, ACCESS_ALL_DATA, REGISTER_CHILD, EDIT_CHILD,CREATE_EDIT_USERS,VIEW_USERS].sort
  end

  def self.all_including_default
    [ ADMIN, LIMITED, ACCESS_ALL_DATA ].sort
  end
end
