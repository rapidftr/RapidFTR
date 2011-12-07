
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

Then /^I should see the description text "([^\"]*)" for form section "([^\"]*)"$/ do |expected_description, form_section|
  row_for(form_section).should have_css("td", :text => expected_description)
end

Then /^I should see the name "([^\"]*)" for form section "([^\"]*)"$/ do |expected_name, form_section|
  row_for(form_section).should have_css("td:nth-child(3)", :text => expected_name)
end

def row_for(section_name)
  page.find "//tr[@id='#{section_name}_row']"
end

