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

