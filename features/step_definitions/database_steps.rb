Given /^an? (user|admin|senior official|registration worker) "([^\"]*)" with(?: a)? password "([^\"]*)"(?: and "([^\"]*)" permission)?$/ do |user_type, username, password, permission|
  case user_type
    when 'user'
      DataPopulator.new.create_user(username, password, permission)
    when 'admin'
      DataPopulator.new.create_admin(username, password, permission)
    when 'senior official'
      DataPopulator.new.create_senior_official(username, password, permission)
    when 'registration worker'
      DataPopulator.new.create_registration_worker(username, password, permission)

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
  expect(User.find_by_user_name(username)).to be_disabled
end

Then /^user "(.+)" should not be disabled$/ do |username|
  expect(User.find_by_user_name(username)).not_to be_disabled
end

Then /^device "(.+)" should be blacklisted/ do |imei|
  devices = Device.find_by_device_imei(imei)
  devices.each do |device|
    expect(device[:blacklisted]).to be true
  end
end

Then /^device "(.+)" should not be blacklisted/ do |imei|
  devices = Device.find_by_device_imei(imei)
  devices.each do |device|
    expect(device[:blacklisted]).to be false
  end
end

Given /^a user "(.+)" has logged in from a device$/ do |user_name|
  user = User.find_by_user_name(user_name)
  user.mobile_login_history << MobileLoginEvent.new(:imei => '45345', :mobile_number => '244534', :timestamp => '2012-12-17 09:53:51 UTC')
  user.save!
end

Given /^I have the following devices:$/ do |table|
  table.hashes.each do |row_hash|
    Device.create(row_hash)
  end
end

Given /^the user's time zone is "([^"]*)"$/ do |timezone|
  step 'I am on the home page'
  step %|I select "#{timezone}" from "Current time zone"|
  step 'I press "Save"'
end

Then /^the field "([^"]*)" of child record with name "([^"]*)" should be "([^"]*)"$/ do |field_name, child_name, field_value|
  children = Child.by_name(:key=>child_name)
  expect(children).not_to be_nil
  expect(children).not_to be_empty
  child = children.first
  expect(child[field_name.to_s]).to eq(field_value)
end

Given /^a password recovery request for (.+)$/ do |username|
  PasswordRecoveryRequest.new(:user_name => username).save
end

When /^I re-enable the user "([^"]*)"$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = false
  user.save
end
