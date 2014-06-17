When /^the user "([^"]*)" checkbox is marked as "([^"]*)"$/ do |username, status|
  select('All',:from => 'filter')
  disabled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  disabled_checkbox.click
  click_button('Yes')
end

When /^I expire my session$/ do
  Clock.stub(:now).and_return(21.minutes.from_now)
end
