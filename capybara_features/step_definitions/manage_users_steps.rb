When /^I "([^"]*)" user "([^"]*)"$/ do |action_link, username|
  cell = within(:xpath, "//table[@id='users']") do
    within(:xpath, "//tr[@id='user-row-#{username}']") do
      find("td", :text=>"#{action_link}")
    end
  end
  cell.should_not be_nil
  cell.find_link("#{action_link}").click
end


Then /^I should see the following users:$/ do |user_table|
  expected_order = user_table.hashes.collect { |user| user['name'] }
  actual_order=page.all(:xpath, "//td[@class='full_name']").collect(&:text)
  actual_order.should == expected_order
end


