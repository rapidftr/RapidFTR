class Permission

  ADMIN = "admin"
  LIMITED = "limited"
  ACCESS_ALL_DATA = "Access all data"

  def self.all
    [ ADMIN, ACCESS_ALL_DATA ].sort
  end

  def self.all_including_default
    [ ADMIN, LIMITED, ACCESS_ALL_DATA ].sort
  end
end
