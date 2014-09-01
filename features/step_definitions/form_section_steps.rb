Then /^I should see the "([^\"]*)" section without an enabled checkbox$/ do |section_name|
  form_section_page.section_should_not_be_enabled(section_name)
end

Then /^I should see the "([^\"]*)" section with an enabled checkbox$/ do |section_name|
  form_section_page.section_should_be_enabled(section_name)
end

Then /^I should see "([^\"]*)" with order of "([^\"]*)"$/ do |section_name, form_order|
  form_section_page.section_should_be_at_index(section_name, form_order)
end

Then /^I should see the following form sections in this order:$/ do |section_names_table|
  section_names = section_names_table.raw.flatten
  form_section_page.should_list_the_following_sections(section_names)
end

Then /^I should see the description text "([^\"]*)" for form section "([^\"]*)"$/ do |expected_description, section_name|
  form_section_page.section_should_have_description(section_name, expected_description)
end

Then /^the form section "([^"]*)" should be listed as visible$/ do |section_name|
  form_section_page.section_should_be_marked_as_visible(section_name)
end

Then /^the form section "([^"]*)" should be listed as hidden$/ do |section_name|
  form_section_page.section_should_be_marked_as_hidden(section_name)
end

When /^I select the form section "([^"]*)" to toggle visibility$/ do |section_name|
  form_section_page.toggle_section_visibility(section_name)
end

When /^I mark "([^"].*)" as searchable$/ do |field_name|
  form_section_edit_page.mark_field_as_searchable field_name
end

When /^I demote field "([^"]*)"$/ do |field|
  # #find(:css, "a##{field}_down").click
  # #drag = page.find("//tr[@data='#{field}']")
  # drag = page.find("//tr[@data='name']")
  # drop = page.find("//tr[@data='second_name']")
  # drag.drag_to(drop)

  # http://your.bucket.s3.amazonaws.com/jquery.simulate.drag-sortable.js
  page.execute_script %{
    $.getScript("https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js/blob/master/jquery.simulate.drag-sortable.js", function() {
      $("tr[data=\'\'#{field}\'\']").simulateDragSortable({ move: 1});
    });}
end

Then /^I should find the form section with following attributes:$/ do |form_section_fields|
  expected_order = form_section_fields.hashes.map { |section_field| section_field['Name'] }
  form_section_page.should_show_fields_in_order(expected_order)
end

When /^I add a new text field with "([^\"]*)" and "([^\"]*)"$/ do |display_name, help_text|
  form_section_page.create_text_field(display_name, help_text)
end

Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |_link, _section_name|
  form_section_page.should_not_see_the_manage_fields_link
end

Then /^I land in edit page of form (.+)$/ do  |section_name|
  form_section_page.should_be_editing_section(section_name)
end

When /^I click Cancel$/ do
  form_section_page.cancel
end

Then /^the view_and_download_reports checkbox should be assignable$/ do
  form_section_page.should_have_view_and_download_reports_section_selected
end

When /^I fill the following options into "([^"]*)":$/ do |label, string|
  fill_in(label, :with => string)
end

private

def form_section_page
  @_form_section_page ||= FormSectionPage.new(Capybara.current_session)
end
