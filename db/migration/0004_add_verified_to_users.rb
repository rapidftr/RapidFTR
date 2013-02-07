User.all.each do |user|
    user.verified = true if user.verified.nil?
	user.save!
end