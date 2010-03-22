Given /^a user "([^\"]*)" with a password "([^\"]*)"$/ do |username, password|
 @user = User.new(:user_name=>username, :password=>password, :password_confirmation=>password, :user_type=>"Administrator", :full_name=>username, :email=>"#{username}@test.com")
 @user.save!
end

Given /^user "(.+)" is disabled$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = true
  user.save!
end

Given /^no users exist$/ do
  users = User.all
  users.each {|user| user.destroy}
end

Given /^no children exist$/ do
  Child.all.each{|child| child.destroy }
end
