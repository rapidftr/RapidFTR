class Permission

  ADMIN = "admin"
  ACCESS_ALL_DATA = "Access all data"
  REGISTER_CHILD = "Register Child"
  EDIT_CHILD = "Edit Child"

  def self.all
    [ADMIN, ACCESS_ALL_DATA, REGISTER_CHILD, EDIT_CHILD].sort
  end

end
