Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |link, section_name|
  row = Hpricot(response.body).search("tr[@id=basic_details_row]").first

  row.inner_html.should_not include(link)
end

Then /^I should see the "([^\"]*)" section without any ordering links$/ do |section_name|
  row = Hpricot(response.body).search("tr[@id=#{section_name}_row]").first
  row.search("span.moveUp").should be_empty
  row.search("span.moveDown").should be_empty
end

When /^I add a new text field with "([^\"]*)" and "([^\"]*)"$/ do |display_name, help_text|
  When 'I follow "Add Custom Field"'
  And 'I follow "Text Field"'
  And "I fill in \"#{display_name}\" for \"Display name\""
  And "I fill in \"#{help_text}\" for \"Help text\""
  And 'I press "Create"'
end

Then /^I should not see the "([^\"]*)" arrow for the "([^\"]*)" field$/ do |arrow_name, field_name|
  row = Nokogiri::HTML(response.body).css("##{field_name}Row").first
  row.inner_html.should_not include(arrow_name)
end

Then /^I should see the "([^\"]*)" arrow for the "([^\"]*)" field$/ do |arrow_name, field_name|
  row = Nokogiri::HTML(response.body).css("##{field_name}Row").first
  row.content.should include(arrow_name)
end

And /^I click the "([^\"]*)" arrow on "([^\"]*)" field$/ do |arrow_name, field_name|
  click_button("#{field_name}_#{arrow_name}")
end

When /^I press "([^\"]*)" next to "([^\"]*)"/ do |direction, unique_id|
  click_link("#{unique_id}_#{direction}")
end

Then /^I should see an order of "([^\"]*)" next to "([^\"]*)"/ do |order, unique_id|
end

Then /^the "([^\"]*)" field should be above the "([^\"]*)" field$/ do |first_field_name, second_field_name|
  table_rows = Nokogiri::HTML(response.body).css("table tr")
  row_ids = table_rows.collect {|row| row[:id]}

  index_of_first_row = row_ids.index(first_field_name + "Row")
  index_of_second_row = row_ids.index(second_field_name + "Row")

  index_of_first_row.should < index_of_second_row
end

Then /^the "([^\"]*)" dropdown should default to "([^\"]*)"$/ do |field, value|
  response_body.should have_selector("select[name='child[my_blank_dropdown_test]'] option[selected][value='']")
end

Given /^I fill in options for "([^\"]*)"$/ do |field_label|
  fill_in(field_label, :with => "Option 1\r\nOption 2\r\nOption 3")
end

Given /^I create a new form called "([^\"]*)"$/ do |form_name|
  FormSection.create_new_custom form_name
end

Then /^I should see "([^\"]*)" with order of "([^\"]*)"$/ do |form_name, form_order|
  # Convert form name into unique_id, find this row, find order, make sure matches form_order
  row = Hpricot(response.body).at("tr[@id=#{form_name}_row]")
  order = row.at("span[@class='formSectionOrder']").inner_html
  order.should == form_order
end
