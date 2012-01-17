
Then /^I should see the "([^\"]*)" section without any ordering links$/ do |section_name|
  row = row_for section_name
  row.should_not have_css("span.moveUp")
  row.should_not have_css("span.moveDown")
end

Then /^I should see the "([^\"]*)" section with(out)? an enabled checkbox$/ do |section_name, without|
  should = without ? :should_not : :should
  row_for(section_name).send(should, have_css("input#sections_#{section_name}"))
end

Then /^I should see "([^\"]*)" with order of "([^\"]*)"$/ do |section_name, form_order|
  row_for(section_name).find(".//span[@class='formSectionOrder']").text.should == form_order
end

Then /^I should see the following form sections in this order:$/ do |table|
  all(:css, "#form_sections tbody tr").map {|e| e['id'].sub(/_row$/,'') }.should == table.raw.flatten
end

Then /^I should see the description text "([^\"]*)" for form section "([^\"]*)"$/ do |expected_description, form_section|
  row_for(form_section).should have_css("td", :text => expected_description)
end

Then /^I should see the name "([^\"]*)" for form section "([^\"]*)"$/ do |expected_name, form_section|
  row_for(form_section).should have_css("td:nth-child(3)", :text => expected_name)
end

Then /^the form section "([^"]*)" should be listed as (visible|hidden)$/ do |form_section, visibility|
  within row_xpath_for(form_section) do
    page.should have_css("td", :text => visibility.capitalize)
  end
end

When /^I select the form section "([^"]*)" to toggle visibility$/ do |form_section|
  check form_section_visibility_checkbox_id(form_section)
end

When /^I (show|hide) selected form sections$/ do |show_or_hide|
  click_button show_or_hide.capitalize
  page.driver.browser.switch_to.alert.accept
end

Then /^the form section "([^"]*)" should not be selected to toggle visibility$/ do |form_section|
  find_field(form_section_visibility_checkbox_id(form_section)).should_not be_checked
end


def row_for(section_name)
  page.find row_xpath_for(section_name)
end

def row_xpath_for(section_name)
  "//tr[@id='#{section_name}_row']"
end

def form_section_visibility_checkbox_id(section_name)
  "sections_#{section_name}"
end

