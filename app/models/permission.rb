class Permission

  ADMIN = "admin"
  LIMITED = "limited"
  ACCESS_ALL_DATA = "Access all data"
  REGISTER_CHILD = "Register Child"
  EDIT_CHILD = "Edit Child"

  def self.all
    [ ADMIN, ACCESS_ALL_DATA ].sort
  end

  def self.all_including_default
    [ ADMIN, LIMITED, ACCESS_ALL_DATA ].sort
  end
end
