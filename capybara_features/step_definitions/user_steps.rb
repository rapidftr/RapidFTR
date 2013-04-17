When /^I disable user$/ do
  find(:xpath,"//input[@class='user-disabled-status']").click
  click_button("Yes")
end

When /^I re\-enable user$/ do
  select("All",:from => "filter")
  find(:xpath,"//input[@class='user-disabled-status']").click
  click_button("Yes")
  sleep 5
end

When /^the user "([^"]*)" is marked as disabled$/ do |username|
  disabled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  disabled_checkbox.click
  click_button("Yes")
end

When /^the user "([^"]*)" is marked as enabled$/ do |username|
  select('All',:from=>'filter')
  disabled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  disabled_checkbox.click
  click_button("Yes")
end
When /^I re-enable user "([^"]*)"$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = "true"
  user.save
end