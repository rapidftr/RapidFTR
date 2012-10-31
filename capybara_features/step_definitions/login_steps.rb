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
  step "I press \"Log in\""
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
  step "I fill in \"#{User.first.user_name}\" for \"user_name\""
  step "I fill in \"123\" for \"password\""
  step "I press \"Log in\""
end

Given /^I am logged in as a user with "(.+)" permissions?$/ do |permissions|
  step "\"mary\" logs in with \"#{permissions}\" permissions"
end

Given /^there is a admin$/ do
	step "a admin \"admin\" with a password \"123\""
end
