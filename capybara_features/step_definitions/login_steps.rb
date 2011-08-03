Given /^I am logged in$/ do
  Given "there is a User"
  Given "I am on the login page"
  Given "I fill in \"#{User.first.user_name}\" for \"user_name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log in\""
end

Given /^I am logged in as an admin$/ do
  Given "there is a admin"
  Given "I am on the login page"
  Given "I fill in \"admin\" for \"user_name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log in\""
end



Given /there is a User/ do
  unless @user
    Given "a user \"mary\" with a password \"123\""
  end
end

Given /^there is a admin$/ do
	Given "a admin \"admin\" with a password \"123\""
end


