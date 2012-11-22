User.all.each do |user|  

  if user.keys.include? "role_names"
    user.role_ids= user["role_names"].map do |role_name| 
      role = Role.find_by_name(role_name)
      role.id if role
    end
    user.organisation = 'N/A'
    user.save!
  end

end