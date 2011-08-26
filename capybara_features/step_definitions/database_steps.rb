Given /^an? (user|admin) "([^\"]*)" with(?: a)? password "([^\"]*)"$/ do |user_type, username, password|
  user_type = user_type == 'user' ? 'User' : 'Administrator'
  @user = User.new(
    :user_name=>username, 
    :password=>password, 
    :password_confirmation=>password, 
    :user_type=> user_type, 
    :full_name=>username, 
    :email=>"#{username}@test.com")
  @user.save!
end

Given /^an? (user|admin) "([^"]+)"$/ do |user_type, user_name|
  Given %(a #{user_type} "#{user_name}" with password "123")
end

Given /^I am logged in as "(.+)"/ do |user_name|
  @session = Session.for_user(User.find_by_user_name(user_name), nil)
  @session.save!
  @session.put_in_cookie cookies
end

Given /^I have an expired session/ do
  @session.destroy
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

Given /^the following admin contact info:$/ do |table|
  contact_info = table.hashes.inject({}) do |result, current|
    result[current["key"]] = current["value"]
    result
  end
  contact_info[:id] = "administrator"
  ContactInformation.create contact_info
end

Given /^the user's time zone is "([^"]*)"$/ do |timezone|
	Given %Q|I am on the home page|
  When %Q|I select "#{timezone}" from "Current time zone"|
  And %Q|I press "Save"|
end




