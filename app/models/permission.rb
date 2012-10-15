class Permission

  ADMIN = "admin"
  LIMITED = "limited"
  ACCESS_ALL_DATA = "Access all data"

  def self.all
    [ ADMIN, LIMITED, ACCESS_ALL_DATA ].sort
  end

end
