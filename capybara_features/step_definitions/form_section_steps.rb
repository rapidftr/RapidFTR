Then /^I should see the "([^\"]*)" section with(out)? an enabled checkbox$/ do |section_name, without|
  should = without ? :should_not : :should
  row_for(section_name).send(should, have_css("input[id^='sections_'][type='checkbox']"))
end

Then /^I should see "([^\"]*)" with order of "([^\"]*)"$/ do |section_name, form_order|
  #row_for(section_name).find("//span[@class='formSectionOrder']").text.should == form_order
  page.should have_xpath("//table[@id='form_sections']/tbody/tr[#{form_order}]/td/a[text()='#{section_name}']")
end

Then /^I should see the following form sections in this order:$/ do |section_names_table|
  section_names = section_names_table.raw.flatten
  form_section_page.should_list_the_following_sections(section_names)
end

Then /^I should see the description text "([^\"]*)" for form section "([^\"]*)"$/ do |expected_description, form_section|
  form_section_page.section_should_have_description(form_section, expected_description)
end

Then /^the form section "([^"]*)" should be listed as (visible|hidden)$/ do |form_section, visibility|
  #within row_xpath_for(form_section) do
  #  page.should have_css("td[3] input", :checked  => (visibility == 'hidden'))
  #end
  checkbox = page.find("//a[@class='formSectionLink' and contains(., '#{form_section}')]/ancestor::tr/td[3]/input[@class='field_hide_show']")
  if visibility == 'hidden'
    checkbox.should be_checked
  else
    checkbox.should_not be_checked
  end
end

When /^I select the form section "([^"]*)" to toggle visibility$/ do |form_section|
  form_section_page.toggle_section_visibility(form_section)
end

Then /^the form section "([^"]*)" should not be selected to toggle visibility$/ do |form_section|
  find_field(form_section_visibility_checkbox_id(form_section)).should_not be_checked
end

When /^I demote field "([^"]*)"$/ do |field|
  ##find(:css, "a##{field}_down").click
  ##drag = page.find("//tr[@data='#{field}']")
  #drag = page.find("//tr[@data='name']")
  #drop = page.find("//tr[@data='second_name']")
  #drag.drag_to(drop)

  #http://your.bucket.s3.amazonaws.com/jquery.simulate.drag-sortable.js
  page.execute_script %{
    $.getScript("https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js/blob/master/jquery.simulate.drag-sortable.js", function() {
      $("tr[data=\'\'#{field}\'\']").simulateDragSortable({ move: 1});
    });}
end

Then /^I should find the form section with following attributes:$/ do |form_section_fields|
  expected_order = form_section_fields.hashes.collect { |section_field| section_field['Name'] }
  form_section_page.should_show_fields_in_order(expected_order)
end

When /^I add a new text field with "([^\"]*)" and "([^\"]*)"$/ do |display_name, help_text|
  form_section_page.create_text_field(display_name, help_text)
end

Then /^I should not see the "([^\"]*)" link for the "([^\"]*)" section$/ do |link, section_name|
  form_section_page.should_not_see_the_manage_fields_link
end

def row_for(section_name)
  page.find row_xpath_for(section_name)
end

def row_xpath_for(section_name)
  "//a[@class='formSectionLink' and contains(., '#{section_name}')]/ancestor::tr"
end

def form_section_visibility_checkbox_id(section_name)
  "sections_#{section_name}"
end

Then /^I land in edit page of form (.+)$/ do  |section_name|
  form_section_page.should_be_editing_section(section_name)
end

When /^I click Cancel$/ do
  form_section_page.cancel
end

Then /^the "([^"]*)" checkbox should be assignable$/ do |field|
  form_section_page.should_have_view_and_download_reports_section_selected
end

private

def form_section_page
  FormSectionPage.new(Capybara.current_session)
end