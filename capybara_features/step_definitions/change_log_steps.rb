
Then /^I should see change log of creation by user "(.*?)"$/ do |user_name|
  page.has_content?("UTC Record created by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}").should be_true
end

Then /^I should see change log for initially setting the field "(.*?)" to value "(.*?)" by "(.*?)"$/ do |field, value, user_name|
  page.has_content?("#{field} initially set to #{value} by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}").should be_true
end

Then /^I should see change log for changing value of field "(.*?)" from "(.*?)" to value "(.*?)" by "(.*?)"$/ do |field,from,to, user_name|
  page.has_content?("#{field} changed from #{from} to #{to} by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation}").should be_true
end

Then /^I should see change log for record flag by "(.*?)" for "(.*?)"$/ do |user_name, reason|
  page.has_content?("Record was flagged by #{user_name} belonging to #{User.find_by_user_name(user_name).organisation} because: #{reason}").should be_true
end

Then /^I should see the following log entry:$/ do |table|
  number_of_records = table.hashes.size
  table.hashes.each do |log_hash|
    child_id = Child.by_unique_identifier(:key => log_hash[:unique_id]).first.id
    page.has_content?("#{log_hash[:type]} of #{number_of_records} records performed by #{log_hash[:user_name]} belonging to #{log_hash[:organization]}").should be_true if number_of_records > 1
    page.has_content?("#{log_hash[:type]} of child with id #{child_id} performed by #{log_hash[:user_name]} belonging to #{log_hash[:organization]}").should be_true if number_of_records == 1
  end
end

Then /^I save file with password "(.+)"$/ do |password|
  step "I fill in \"password\" with \"#{password}\""
  step "I press \"OK\""
end
