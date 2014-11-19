When /^the user "([^"]*)" checkbox is marked as "([^"]*)"$/ do |username, _status|
  select('All', :from => 'filter')
  disabled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  disabled_checkbox.click
  click_button('Yes')
end

When /^I expire my session$/ do
  Clock.stub(:now).and_return(21.minutes.from_now)
end

When /^I enter the following user details$/ do |user_table|
  user_table.hashes.each do |user_row|
    fill_in('user_full_name', :with => user_row['user_full_name'])
    fill_in('user_user_name', :with => user_row['user_user_name'])
    fill_in('user_password', :with => user_row['user_password'])
    fill_in('user_password_confirmation', :with => user_row['user_password_confirmation'])
    [user_row['user_roles']].flatten.each do |roles|
      check(roles)
    end
    fill_in('user_phone', :with => user_row['user_phone'])
    fill_in('user_email', :with => user_row['user_email'])
    fill_in('user_organisation', :with => user_row['user_organisation'])
    fill_in('user_position', :with => user_row['user_position'])
    fill_in('user_location', :with => user_row['user_location'])
  end
end

When /^I submit the create user form$/ do
  click_button('Create')
end

And /^I should see the user with the following info$/ do |user_table|
  user_table.hashes.each do |user_row|
    expect(page).to have_content(user_row['user_full_name'])
    expect(page).to have_content(user_row['user_user_name'])
    expect(page).to have_content(user_row['user_roles'])
    expect(page).to have_content(user_row['user_phone'])
    expect(page).to have_content(user_row['user_email'])
    expect(page).to have_content(user_row['user_organisation'])
    expect(page).to have_content(user_row['user_position'])
    expect(page).to have_content(user_row['user_location'])
  end
end