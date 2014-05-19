Then /^I should not be able to edit "([^\"]*)" field$/ do |field_name|
  edit_field_selector = "//td[text()=\"#{field_name}\"]/parent::*/td/div/select"
  page.should have_no_selector(:xpath, edit_field_selector)
end

Then /^I should be able to edit "([^\"]*)" field$/ do |field_name|
  edit_field_selector = "//td[text()=\"#{field_name}\"]/parent::*/td/div/select"
  page.should have_selector(:xpath, edit_field_selector)
end

Then /^(?:|I )move field "([^"]*)" to form "([^"]*)"$/ do |field_name, form_name|
   #//td[text()='#{field_name}']/parent::tr/td[6]/a
   page.find("//tr[@data='#{field_name}']/td[6]/a").click
   sleep 1.to_i
   page.select(form_name, :from => "#{field_name}_destination_form_id")
end
