When /^I disable user$/ do
  find(:xpath,"//input[@class='user-disabled-status']").click
  click_button("Yes")
end

When /^I re\-enable user$/ do
  select("All",:from => "filter")
  find(:xpath,"//input[@class='user-disabled-status']").click
  click_button("Yes")
end
