When /^I enter the following role details$/ do |role_table|
  role_table.hashes.each do |role_row|
    fill_in("role_name",:with => role_row['name'])
    fill_in("role_description",:with => role_row['description'])
    role_row['permissions'].each do |permission|
      check(permission)
    end
  end
end

And /^I submit the form$/ do
  click_button('Save')
end

And /^I see the following roles$/ do |role_table|
  role_table.hashes.each do |role_row|
    page.should have_content(role_row['name'].titleize)
    page.should have_content(role_row['description'])
  end

end

Then /^I should see error messages$/ do
  page.should have_content("Please select at least one permission")
  page.should have_content("Name must not be blank")
end

Then /^I should see message "([^"]*)"$/ do |error_message|
  page.should have_content(error_message)
end

When /^I try to filter user roles by permission "([^"]*)"$/ do |permission|
  click_link('USERS')
  click_link('Roles')
  select(permission, :from => 'show')
end

Then /^I should see the following users:$/ do |table|
  table.rows.each do |user|
    within("//table[@class='list_table']") do
      assert page.has_content?(user.first)
    end
  end
end