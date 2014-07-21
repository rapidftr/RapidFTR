User.all.each do |user|
  user.verified ||= true
  user.save!
end
