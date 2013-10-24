Given /^I am logged in$/ do
  step "there is a User"
  login_page.login_as(User.first.user_name, '123')
end

Given /^I am logged in as an admin$/ do
  step "there is a admin"
  login_page.login_as('admin', '123')
end

Given /^I am logged in as "(.+)"/ do |user_name|
  login_page.login_as(user_name, '123')
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
  login_page.login_as(user_name, '123')
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
  login_page.login_as(user_name, password)
end

Given /^I logout as "([^"]*)"$/ do |arg|
  click_link(I18n.t("header.logout"))
end

When /^I logout$/ do
  click_link(I18n.t("header.logout"))
end

private

def login_page
  LoginPage.new(Capybara.current_session)
end
