Then /^I should not be able to edit "([^\"]*)" field$/ do |field_name|
  form_section_edit_page.should_not_be_able_to_edit_field(field_name)
end

Then /^I should be able to edit "([^\"]*)" field$/ do |field_name|
  form_section_edit_page.should_be_able_to_edit_field(field_name)
end

When /^I hide the Nationality field$/ do
  form_section_edit_page.mark_nationality_field_as_hidden
end

private

def form_section_edit_page
  @_form_section_edit_page ||= FormSectionEditPage.new(Capybara.current_session)
end

Then /^(?:|I )move field "([^"]*)" to form "([^"]*)"$/ do |field_name, form_name|
  # //td[text()='#{field_name}']/parent::tr/td[6]/a
  page.find("//tr[@data='#{field_name}']/td[6]/a").click
  sleep 1.to_i
  page.select(form_name, :from => "#{field_name}_destination_form_id")
end
