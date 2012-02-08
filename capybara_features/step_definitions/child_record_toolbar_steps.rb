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

When /^I click mark as duplicate for "([^"]*)"$/ do |child_name|
  child_with_specified_name = Child.all.detect { |c| c.name == child_name }
  page.find_by_id("child_#{child_with_specified_name._id}").click_link("Mark as Duplicate")
end