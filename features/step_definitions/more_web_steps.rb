require 'uri'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'support', 'paths'))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

When /^I click text "([^"]*)"(?: within "([^\"]*)")?$/ do |text_value, selector|
  with_scope(selector) do
    page.find('//a', :visible => true, :text => text_value).click
  end
end

Then /^the "([^\"]*)" field should be disabled$/ do |label|
  expect(field_labeled(label, :disabled => true)[:disabled]).to be_truthy
end

Given /^devices exist$/ do |devices|
  devices.hashes.each do |device_hash|
    device = Device.new(:imei => device_hash[:imei], :blacklisted => device_hash[:blacklisted], :user_name => device_hash[:user_name])
    device.save!
  end
end

Then /^I should find the form with following attributes:$/ do |table|
  table.raw.flatten.each do |attribute|
    expect(page).to have_field(attribute)
  end
end

When /^I uncheck the disabled checkbox for user "([^"]*)"$/ do |username|
  page.find("//tr[@id='user-row-#{username}']/td/input[@type='checkbox']").click
  click_button('Yes')
end

Then /^I should (not )?see "([^\"]*)" with id "([^\"]*)"$/ do |do_not_want, element, id|
  should = do_not_want ? :should_not : :should
  page.send(should, have_css("##{id}"))
end

And /^I check the device with an imei of "([^\"]*)"$/ do |imei_number|
  find(:css, ".blacklisted-checkbox-#{imei_number}").set(true)
end

def get_user_row_element(full_name)
  page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]")
end

Then /^user "([^\"]*)" should exist on the page$/ do |full_name|
  expect { get_user_row_element(full_name) }.not_to raise_error
end

Then /^user "([^\"]*)" should not exist on the page$/ do |full_name|
  expect { get_user_row_element(full_name) }.to raise_error(Capybara::ElementNotFound)
end

Then /^I should not see "([^\"]*)" for record "([^\"]*)"$/ do |text, full_name|
  child_summary_panel = page.find(:xpath, "//div[text()=\"#{full_name}\"]/parent::*/parent::*")
  expect(child_summary_panel).not_to have_content(text);
end

Then /^I should see "([^\"]*)" for record "([^\"]*)"$/ do |text, full_name|
  child_summary_panel = page.find(:xpath, "//div[text()=\"#{full_name}\"]/parent::*/parent::*")
  expect(child_summary_panel).to have_content(text);
end

def get_element_for_edit_user_link(full_name, link)
  page.find(:xpath, "//tr[@id=\"user-row-#{full_name}\"]/td/a[text()=\"#{link}\"]")
end

Then /^I should see "([^\"]*)" for "([^\"]*)"$/ do |link, full_name|
  expect { get_element_for_edit_user_link(full_name, link) }.not_to raise_error
end

Then /^I should not see "([^\"]*)" for "([^\"]*)"$/ do |link, full_name|
  expect { get_element_for_edit_user_link(full_name, link) }.to raise_error(Capybara::ElementNotFound)
end

Then /^the field "([^"]*)" should have the following options:$/ do |locator, table|
  expect(page).to have_select(locator, :options => table.raw.flatten)
end

def get_link_for_page(page_name)
  page.find(:xpath, "//a[@href=\"#{path_to(page_name)}\"] ")
end

Then /^(?:|I )should see a link to the (.+)$/ do |page_name|
  expect { get_link_for_page(page_name) }.not_to raise_error
end

Then /^I should not be able to see (.+)$/ do |page_name|
  visit path_to(page_name)
  expect(page.status_code).to eq(403)
end

Then /^I should be able to see (.+)$/ do |page_name|
  step "I am on #{page_name}"
  step "I should be on #{page_name}"
end

And /^the user "([^\"]*)" should be marked as (disabled|enabled)$/ do |username, status|
  disbled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  if status == 'disabled'
    expect(disbled_checkbox).to be_checked
  else
    expect(disbled_checkbox).not_to be_checked
  end
end

Then /^I should see an audio element that can play the audio file named "([^"]*)"$/ do |filename|
  url = current_url.gsub '/edit', ''
  expect(page.body).to have_selector("//audio/source[@src='#{url}/audio']")
end

Then /^I should not see an audio tag$/ do
  expect(page.body).not_to have_selector('//audio')
end

When /^I visit the "([^"]*)" tab$/ do |name_of_tab|
  click_link name_of_tab
end

Then /^the "([^"]*)" radio_button should have the following options:$/ do |radio_button, table|
  radio = Nokogiri::HTML(page.body).css("p##{radio_button.downcase.gsub(' ', '')}")
  expect(radio).not_to be_nil
  table.raw.each { |row| expect(radio.css('label').map(&:text)).to include row.first }

end

Then /^the "([^"]*)" dropdown should have the following options:$/ do |dropdown_label, table|
  options = table.hashes
  page.has_select?(dropdown_label, :options => options.collect { |element| element['label'] },
                                   :selected => options.collect { |element| element['label'] if element['selected?'] == 'yes' }.compact!)
end

Then /^I should find the following links:$/ do |table|
  table.rows_hash.each do |label, named_path|
    href = path_to(named_path)
    expect(page).to have_xpath "//a[@href='#{href}' and text()='#{label}']"
  end
end

Then /^the "([^"]*)" checkboxes should have the following options:$/ do |checkbox_name, table|
  checkbox_label = page.find "//label[contains(., '#{checkbox_name}')]"
  checkbox_id = checkbox_label['for'].split('_').last
  checkbox_elements = Nokogiri::HTML(page.body).css("input[type='checkbox'][name='child[#{checkbox_id}][]']")

  checkboxes = checkbox_elements.each_with_object({}) do |element, result|
    result[element['value']] = !!element[:checked]
  end

  table.hashes.each do |expected_checkbox|
    expected_value = expected_checkbox['value']
    should_be_checked = (expected_checkbox['checked?'] == 'yes')
    expect(checkboxes).to have_key expected_value
    expect(checkboxes[expected_value]).to eq(should_be_checked)

  end
end

When /^I check "([^"]*)" for "([^"]*)"$/ do |value, checkbox_name|
  label = page.find '//label', :text => checkbox_name
  checkbox_id = label['for'].split('_').last
  page.check("child_#{checkbox_id}_#{value.dehumanize}")
end

When /^I click the "(.*)" button$/ do |button_value|
  click_button button_value
end

When /^I click the "(.*)" link$/ do |link|
  click_link link
end
