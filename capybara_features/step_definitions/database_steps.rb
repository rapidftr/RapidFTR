Given /^an? (user|admin) "([^\"]*)" with(?: a)? password "([^\"]*)"(?: and "([^\"]*)" permission)?$/ do |user_type, username, password, permission|
  user_type = user_type == 'user' ? 'User' : 'Administrator'
  @user = User.new(
    :user_name=>username, 
    :password=>password, 
    :password_confirmation=>password, 
    :user_type=> user_type, 
    :full_name=>username, 
    :email=>"#{username}@test.com",
    :permission=> permission ? (permission=='limited' ? Permission::LIMITED : Permission::UNLIMITED) : Permission::UNLIMITED )
  @user.save!
end

Given /^an? (user|admin) "([^"]+)"$/ do |user_type, user_name|
  Given %(a #{user_type} "#{user_name}" with password "123")
end

Given /^an? (user|admin) "([^"]+)" with "(limited|unlimited)" permission$/ do |user_type, user_name, permission|
  Given %(a #{user_type} "#{user_name}" with password "123" and "#{permission}" permission)
end

Given /^I have an expired session/ do
  Session.all.each do |session|
     session.destroy
  end
end

Given /^user "(.+)" is disabled$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = "true"
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

Then /^the field "([^"]*)" of child record with name "([^"]*)" should be "([^"]*)"$/ do |field_name, child_name, field_value|
  children = Child.by_name(:key=>child_name)
  children.should_not be_nil
  children.should_not be_empty
  child = children.first
  child[field_name.to_s].should == field_value
end
