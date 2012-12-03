Then /^I should see the following links in the toolbars:$/ do |links_table|
  divs = page.all :xpath, '//div[@class="profile-tools"]'
  divs.each do |div|
    links_table.hashes.each do |link_hash|
      check_link_presence(div, link_hash['link_class_name'], link_hash['link_text'])
    end
  end
end

When /^I click the "(.*)" button$/ do |button_value|
  click_button button_value
end

And /^I mark "([^\"]*)" as investigated with the following details:$/ do |name, details|
<<<<<<< HEAD
  click_span("Mark as Investigated")
=======
  click_link("Investigate Record")
>>>>>>> #Features - Suganthi - Fixed suspect records and flag child record feature
  fill_in("Investigation Details", :with => details)
  click_button("Investigate Record")
end

And /^I mark "([^\"]*)" as not investigated with the following details:$/ do |name, details|
<<<<<<< HEAD
  click_span("Mark as Not Investigated")
=======
  click_link("Undo Investigated")
>>>>>>> #Features - Suganthi - Fixed suspect records and flag child record feature
  fill_in("Undo Investigation Details", :with => details)
  click_button("Undo Investigated")
end

When /^I click mark as duplicate for "([^"]*)"$/ do |child_name|
  child_with_specified_name = Child.all.detect { |c| c.name == child_name }
  page.find_by_id("child_#{child_with_specified_name._id}").click_link("Mark as Duplicate")
end

When /^I click blacklist for "([^"]*)"$/ do |imei|
  page.find_by_id("#{imei}").click
end

def click_span(locator)
  find(:xpath, "//span[text()='#{locator}']").click
end
