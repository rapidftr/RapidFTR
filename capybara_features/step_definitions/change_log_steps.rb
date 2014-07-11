Then /^I should see change log of creation by user "(.*?)"$/ do |user_name|
  expect(page).to have_content("UTC Record created by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}")
end

Then /^I should see change log for initially setting the field "(.*?)" to value "(.*?)" by "(.*?)"$/ do |field, value, user_name|
  expect(page).to have_content("#{field} initially set to #{value} by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}")
end

Then /^I should see change log for changing value of field "(.*?)" from "(.*?)" to value "(.*?)" by "(.*?)"$/ do |field,from,to, user_name|
  expect(page).to have_content("#{field} changed from #{from} to #{to} by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}")
end

Then /^I should see change log for record flag by "(.*?)" for "(.*?)"$/ do |user_name, reason|
  expect(page).to have_content("Record was flagged by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation} because: #{reason}")
end
