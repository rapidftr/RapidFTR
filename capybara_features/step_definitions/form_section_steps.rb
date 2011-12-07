
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

def row_for(section_name)
  page.find "//tr[@id='#{section_name}_row']"
end

