Child.all.each do |child|
	child.verified ||= true
	child.save!
end