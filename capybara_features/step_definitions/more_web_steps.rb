require 'uri'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

When /^I click text "([^"]*)"(?: within "([^\"]*)")?$/ do |text_value, selector|
  with_scope(selector) do
    page.find('//a', :text => text_value).click
  end
end

Then /^the "([^\"]*)" field should be disabled$/ do |label|
  field_labeled(label)[:disabled].should be_true
end

Given /^devices exist$/ do |devices|
  devices.hashes.each do |device_hash|
    device = Device.new(:imei => device_hash[:imei], :blacklisted => device_hash[:blacklisted], :user_name => device_hash[:user_name])
    device.save!
  end
end

Then /^I should find the form with following attributes:$/ do |table|
  table.raw.flatten.each do |attribute|
    page.should have_field(attribute)
  end
end

When /^I uncheck the disabled checkbox for user "([^"]*)"$/ do |username|
  page.find("//tr[@id='user-row-#{username}']/td/input[@type='checkbox']").click
  click_button("Yes")
end

Then /^I should (not )?see "([^\"]*)" with id "([^\"]*)"$/ do |do_not_want, element, id|
  puts "Warning: element argument '#{element}' is ignored."
  should = do_not_want ? :should_not : :should
  page.send(should, have_css("##{id}"))
end

And /^I check the device with an imei of "([^\"]*)"$/ do |imei_number|
  find(:css, ".blacklisted-checkbox-#{imei_number}").set(true)
end

Then /^user "([^\"]*)" should exist on the page$/ do |full_name|
  lambda { page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]") }.should_not raise_error(Capybara::ElementNotFound)
end

Then /^user "([^\"]*)" should not exist on the page$/ do |full_name|
  lambda { page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]") }.should raise_error(Capybara::ElementNotFound)
end

Then /^I should see "([^\"]*)" for "([^\"]*)"$/ do |link, full_name|
  lambda { page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]/td/a[text()=\"#{link}\"]") }.should_not raise_error(Capybara::ElementNotFound)
end

Then /^I should not see "([^\"]*)" for "([^\"]*)"$/ do |link, full_name|
  lambda { page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]/td/a[text()=\"#{link}\"]") }.should raise_error(Capybara::ElementNotFound)
end

Then /^the field "([^"]*)" should have the following options:$/ do |locator, table|
  page.should have_select(locator, :options => table.raw.flatten)
end

Then /^(?:|I )should see a link to the (.+)$/ do |page_name|
  page.find(:xpath, "//a[@href=\"#{path_to(page_name)}\"] ")
end

Then /^I should not be able to see (.+)$/ do |page_name|
  visit path_to(page_name)
  page.status_code.should == 403
end

Then /^I should be able to see (.+)$/ do |page_name|
  When "I go to #{page_name}"
  Then "I should be on #{page_name}"
end

Then /^I should see an audio element that can play the audio file named "([^"]*)"$/ do |filename|
  page.body.should have_selector("//audio/source", :src=>current_path + "/audio/")
end

Then /^I should not see an audio tag$/ do
  page.body.should_not have_selector("//audio")
end
