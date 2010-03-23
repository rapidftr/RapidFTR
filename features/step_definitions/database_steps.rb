Given /^a user "([^\"]*)" with a password "([^\"]*)"$/ do |username, password|
 @user = User.new(:user_name=>username, :password=>password, :password_confirmation=>password, :user_type=>"Administrator", :full_name=>username, :email=>"#{username}@test.com")
 @user.save!
end

Given /^user "(.+)" is disabled$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = true
  user.save!
end

Then /^user "(.+)" should be disabled$/ do |username|
  User.find_by_user_name(username).should be_disabled
end

Then /^user "(.+)" should not be disabled$/ do |username|
  User.find_by_user_name(username).should_not be_disabled
end
