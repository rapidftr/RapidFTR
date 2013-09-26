When /^the user "([^"]*)" checkbox is marked as "([^"]*)"$/ do |username, status|
  select("All", :from => "filter")
  disabled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  sleep 1
  disabled_checkbox.click
  click_button("Yes")
  sleep 1
end