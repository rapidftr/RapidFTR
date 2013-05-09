Given /^an? (user|admin|senior official|registration worker) "([^\"]*)" with(?: a)? password "([^\"]*)"(?: and "([^\"]*)" permission)?$/ do |user_type, username, password, permission|

  permissions = []
  permissions.push(Permission.all_permissions) if user_type.downcase == "admin" and permission.nil?
  permissions.push(Permission::CHILDREN[:register]) if user_type.downcase == "user" and permission.nil?
  permissions.push(Permission::REPORTS[:view]) if user_type.downcase == "senior official" and permission.nil?
  permissions.push(Permission::CHILDREN[:edit], Permission::CHILDREN[:register], Permission::CHILDREN[:view_and_search]) if user_type.downcase == "registration worker" and permission.nil?
  permissions.push(Permission.all_permissions) if permission.to_s.downcase.split(',').include?('admin')
  permissions.push(permission.split(",")) if permission
  permissions.flatten!

  role_name = permissions.join("-")
  role = Role.find_by_name(role_name) || Role.create(:name => role_name, :permissions => permissions)

  @user = User.find_by_user_name(username)

  if @user.nil?
    @user = User.new(
        :user_name=>username,
        :password=>password,
        :password_confirmation=>password,
        :full_name=>username,
        :organisation=>"UNICEF",
        :disabled => "false",
        :email=>"#{username}@test.com",
        :role_ids => [role.id]
    )
    @user.save!
  end
end

Given /^an? (user|admin) "([^"]+)"$/ do |user_type, user_name|
  step %(a #{user_type} "#{user_name}" with password "123")
end

Given /^an? (user|admin) "([^"]+)" with "(Register Child|View And Search Child|Edit Child)" permission$/ do |user_type, user_name, permission|
  step %(a #{user_type} "#{user_name}" with password "123" and "#{permission}" permission)
end

Given /^I have an expired session/ do
  Session.all.each do |session|
    session.destroy
  end
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

Then /^device "(.+)" should be blacklisted/ do |imei|
  devices = Device.find_by_imei(imei)
  devices.each do |device|
    device[:blacklisted].should be_true
  end
end

Then /^device "(.+)" should not be blacklisted/ do |imei|
  devices = Device.find_by_imei(imei)
  devices.each do |device|
    device[:blacklisted].should be_false
  end
end

Given /^a user "(.+)" has logged in from a device$/ do |user_name|
  user = User.find_by_user_name(user_name)
  user.mobile_login_history << MobileLoginEvent.new(:imei => "45345", :mobile_number => "244534", :timestamp => "2012-12-17 09:53:51 UTC")
  user.save!
end

Given /^the following admin contact info:$/ do |table|
  contact_info = table.hashes.inject({}) do |result, current|
    result[current["key"]] = current["value"]
    result
  end
  contact_info[:id] = "administrator"
  ContactInformation.create contact_info
end

Given /^I have the following devices:$/ do |table|
  table.hashes.each do |row_hash|
    Device.create(row_hash)
  end
end

Given /^the user's time zone is "([^"]*)"$/ do |timezone|
  step %Q|I am on the home page|
  step %Q|I select "#{timezone}" from "Current time zone"|
  step %Q|I press "Save"|
end

Then /^the field "([^"]*)" of child record with name "([^"]*)" should be "([^"]*)"$/ do |field_name, child_name, field_value|
  children = Child.by_name(:key=>child_name)
  children.should_not be_nil
  children.should_not be_empty
  child = children.first
  child[field_name.to_s].should == field_value
end

Given /^a password recovery request for (.+)$/ do |username|
  PasswordRecoveryRequest.new(:user_name => username).save
end

When /^I re-enable the user "([^"]*)"$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = false
  user.save

end
