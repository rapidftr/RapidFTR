When /^I enter the following role details$/ do |role_table|
  role_table.hashes.each do |role_row|
    fill_in('role_name',:with => role_row['name'])
    fill_in('role_description',:with => role_row['description'])
    [ role_row['permissions'] ].flatten.each do |permission|
      check(permission)
    end
  end
end

And /^I should see the following roles$/ do |role_table|
  role_table.hashes.each do |role_row|
    expect(page).to have_content(role_row['name'].titleize)
    expect(page).to have_content(role_row['description'])
  end
end

Then /^I should see error messages$/ do
  expect(page).to have_content('Please select at least one permission')
  expect(page).to have_content('Name must not be blank')
end

Then /^I should see message "([^"]*)"$/ do |error_message|
  expect(page).to have_content(error_message)
end

When /^I try to filter user roles by permission "([^"]*)"$/ do |permission|
  go_to_roles_page
  select(permission, :from => 'show')
end

When /^I try to filter user roles sorted by "(.*?)"$/ do |order|
  go_to_roles_page
  select(order, :from => 'sort_by_descending_order')
end

Then /^I should see the following roles sorted:$/ do |table|
  expected_order = table.hashes.collect { |role| role['name'] }
  expect(actual_order_against(expected_order)).to eq(expected_order)
end

When /^I edit the role (.+)$/ do  |role_name|
  find(:xpath,"//table[@class='list_table']//tr/td[text()='"+role_name+"']/following-sibling::td/a[text()='Edit']").click()
end

When /^I update the form$/ do
  click_button('Update')
end

When /^I enter the following permission details$/ do |role_table|
  role_table.hashes.each do |role_row|
    [ role_row['permissions'] ].flatten.each do |permission|
      check(permission)
    end
  end
end

def go_to_roles_page
  click_link('USERS')
  click_link('Roles')
end

def actual_order_against(expected_order)
  list = page.all(:xpath, "//td[@class='role_name']").collect(&:text)
  actual_order = []
  list.each { |item| actual_order << item if expected_order.include?(item) }
  actual_order
end
