Then /^I should see the following users:$/ do |user_table|
  expected_order = user_table.hashes.collect { |user| user['name'] }
  actual_order=page.all(:xpath, "//td[@class='full_name']").collect(&:text)
  actual_order.should == expected_order
end
