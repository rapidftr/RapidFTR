Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |link, section_name|
  row = Hpricot(response.body).search("tr[@id=basic_details_row]").first

  row.inner_html.should_not include(link)
end

When /^I add a new text field with "([^\"]*)" and "([^\"]*)"$/ do |name, help_text|
  When 'I follow "Add Custom Field"'
  And 'I follow "TextField"'
  And 'I fill in "#{name}" for "name"'
  And 'I fill in "#{help_text}" for "Help text"'
  And 'I press "Create"'
end

