class Permission

  ADMIN = "admin"
  LIMITED = "limited"
  UNLIMITED = "unlimited"

  def self.all
    [ ADMIN, LIMITED, UNLIMITED ].sort
  end

end
