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
  click_link("Mark record as Investigated")
  fill_in("Investigation Details", :with => details)
  click_button("Mark as Investigated")
end

And /^I mark "([^\"]*)" as not investigated with the following details:$/ do |name, details|
  click_link("Mark as Not Investigated")
  fill_in("Undo Investigation Details", :with => details)
  click_button("Undo Investigated")
end