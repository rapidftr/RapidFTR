Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |link, section_name|
  row = Hpricot(response.body).search("tr[@id=basic_details_row]").first

  row.inner_html.should_not include(link)
end

When /^I add a new text field with "([^\"]*)" and "([^\"]*)"$/ do |name, help_text|
  When 'I follow "Add Custom Field"'
  And 'I follow "Text Field"'
  And "I fill in \"#{name}\" for \"name\""
  And "I fill in \"#{help_text}\" for \"Help text\""
  And 'I press "Create"'
end

Then /^I should not see the "([^\"]*)" arrow for the "([^\"]*)" field$/ do |arrow_name, field_name|
  row = Hpricot(response.body).search("tr[@id=#{field_name}Row]").first
  row.inner_html.should_not include(arrow_name)
end

Then /^I should see the "([^\"]*)" arrow for the "([^\"]*)" field$/ do |arrow_name, field_name|
  row = Hpricot(response.body).search("tr[@id=#{field_name}Row]").first
  row.inner_html.should include(arrow_name)
end

And /^I click the "([^\"]*)" arrow on "([^\"]*)" field$/ do |arrow_name, field_name|
  click_button("#{field_name}_#{arrow_name}")
end

Then /^the "([^\"]*)" field should be above the "([^\"]*)" field$/ do |first_field_name, second_field_name|
  table_rows = Hpricot(response.body).search("table tr")
  row_ids = table_rows.collect {|row| row[:id]}

  index_of_first_row = row_ids.index(first_field_name + "Row")
  index_of_second_row = row_ids.index(second_field_name + "Row")

  index_of_first_row.should < index_of_second_row
end

