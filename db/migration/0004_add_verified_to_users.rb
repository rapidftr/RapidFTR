User.all.each do |user|
  user.verified ||= true
  user.save! unless user.roles.empty?
end
