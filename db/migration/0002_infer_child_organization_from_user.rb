Child.all.each do |child|
  child.save # Triggers initializing organisation from user
end
