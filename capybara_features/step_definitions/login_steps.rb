Given /^I am logged in$/ do
  step "there is a User"
  step "I am on the login page"
  step "I fill in \"#{User.first.user_name}\" for \"user_name\""
  step "I fill in \"123\" for \"password\""
  step "I press \"Log in\""
end

Given /^I am logged in as an admin$/ do
  step "there is a admin"
  step "I am on the login page"
  step "I fill in \"admin\" for \"user_name\""
  step "I fill in \"123\" for \"password\""
  step "I press \"Log in\""
end

Given /^I am logged in as "(.+)"/ do |user_name|
  step "I am on the login page"
  step "I fill in \"#{user_name}\" for \"user_name\""
  step "I fill in \"123\" for \"password\""
  #step "I press \"Log in\""
  find("//input[@class='btn_submit']").click
end



Given /there is a User/ do
  unless @user
    step "a user \"mary\" with a password \"123\" and \"View And Search Child\" permission"
  end
end

Given /there is a user with "(.+)" permissions?/ do |permission|
  step "a user \"mary\" with a password \"123\" and \"#{permission}\" permission"
end

Given /^"([^\"]*)" logs in with "([^\"]*)" permissions?$/ do |user_name, permissions|
  step "a user \"#{user_name}\" with a password \"123\" and \"#{permissions}\" permission"
  step "I am on the login page"
  step "I fill in \"#{user_name}\" for \"user_name\""
  step "I fill in \"123\" for \"password\""
  find("//input[@class='btn_submit']").click
end

Given /^I am logged in as a user with "(.+)" permissions?$/ do |permissions|
  step "\"mary\" logs in with \"#{permissions}\" permissions"
end

Given /^I am logged in as a "(.+)" with "(.+)" permissions?$/ do |username,permissions|
  step "\"#{username}\" logs in with \"#{permissions}\" permissions"
end

Given /^there is a admin$/ do
  step "a admin \"admin\" with a password \"123\""
end
Then /^I am logged in as user (.+) with password as (.+)/ do|user_name,password|
  step "I am on the login page"
  step "I fill in \"#{user_name}\" for \"user_name\""
  step "I fill in \"#{password}\" for \"password\""
  step "I press \"Log in\""

end
#When /^I logout$/ do
#  find("//div[@class='links']/a[@href='/logout']").click
#end


#
Given /^I logout as "([^"]*)"$/ do |arg|
  find("//div[@class='links']/a[@href='/logout']").click
end

When /^I logout$/ do
  click_link("Logout")
end
