class PermissionLevel
  def self.valid? level
    [LIMITED, UNLIMITED].include? level
  end
  
  LIMITED = "Limited"
  UNLIMITED = "Unlimited"
end
