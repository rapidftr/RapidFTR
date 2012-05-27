When /^I "([^"]*)" user "([^"]*)"$/ do |action_link, username|
  cell = within(:xpath, "//table[@id='users']") do
    within(:xpath, "//tr[@id='user-row-#{username}']") do
      find("td", :text=>"#{action_link}")
    end
  end
  cell.should_not be_nil
  cell.find_link("#{action_link}").click
end
