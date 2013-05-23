require 'uri'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Then /^the "([^\"]*)" field should be disabled$/ do |label|
  field_labeled(label, :disabled => true)[:disabled].should be_true
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

Then /^I should not see "([^\"]*)" for record "([^\"]*)"$/ do |text, full_name|
  page.find(:xpath, "//div[text()=\"#{full_name}\"]/parent::*/parent::*").should_not have_content(text);
end


Then /^I should see "([^\"]*)" for record "([^\"]*)"$/ do |text, full_name|
  page.find(:xpath, "//div[text()=\"#{full_name}\"]/parent::*/parent::*").should have_content(text);
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
  step "I am on #{page_name}"
  step "I should be on #{page_name}"
end

And /^the user "([^\"]*)" should be marked as (disabled|enabled)$/ do |username, status|
  disbled_checkbox = find(:css, "#user-row-#{username} td.user-status input")
  if status == "disabled"
    disbled_checkbox.should be_checked
  else
    disbled_checkbox.should_not be_checked
  end
end

Then /^I should see an audio element that can play the audio file named "([^"]*)"$/ do |filename|
  url = current_url.gsub '/edit', ''
  page.body.should have_xpath("//audio/source[@src='#{url}/audio']")
end

Then /^I should not see an audio tag$/ do
  page.body.should_not have_selector("//audio")
end

Then /^the "([^"]*)" radio_button should have the following options:$/ do |radio_button, table|
   radio = Nokogiri::HTML(page.body).css("p##{radio_button.downcase.gsub(" ", "")}")
   radio.should_not be_nil
   table.raw.each { |row| radio.css("label").map(&:text).should include row.first }

end

Then /^the "([^"]*)" dropdown should have the following options:$/ do |dropdown_label, table|
  options = table.hashes
  page.has_select?(dropdown_label, :options => options.collect{|element| element['label']},
                   :selected => options.collect{|element| element['label'] if element['selected?'] == 'yes'}.compact!)
end

Then /^I should find the following links:$/ do |table|
  table.rows_hash.each do |label, named_path|
    href = path_to(named_path)
    page.should have_xpath "//a[@href='#{href}' and text()='#{label}']"  end
end

Then /^the "([^"]*)" checkboxes should have the following options:$/ do |checkbox_name, table|
  checkbox_label = page.find "//label[contains(., '#{checkbox_name}')]"
  checkbox_id = checkbox_label["for"].split("_").last
	checkbox_elements = Nokogiri::HTML(page.body).css("input[type='checkbox'][name='child[#{checkbox_id}][]']")

	checkboxes = checkbox_elements.inject({}) do | result,  element |
		result[element['value']] = !!element[:checked]
		result
  end
  puts "checkboxes #{checkboxes}"

  table.hashes.each do |expected_checkbox|
    expected_value = expected_checkbox['value']
    puts "expected_value #{expected_value}"
    should_be_checked = (expected_checkbox['checked?'] == 'yes')
    checkboxes.should have_key expected_value
		checkboxes[expected_value].should == should_be_checked

  end
end

When /^I check "([^"]*)" for "([^"]*)"$/ do |value, checkbox_name|
  label = page.find '//label', :text => checkbox_name
  checkbox_id = label["for"].split("_").last
	page.check("child_#{checkbox_id}_#{value.dehumanize}")
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  if defined?(Spec::Rails::Matchers)
    page.should have_content(regexp)
  else
    page.text.should match(regexp)
  end
end

Then /^(?:|I )should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^(?:|I )should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      page.should have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/(?: within "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      page.should have_no_xpath('//*', :text => regexp)
    else
      assert page.has_no_xpath?('//*', :text => regexp)
    end
  end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      find_field(field).value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_labeled(field).value)
    end
  end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should not contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      find_field(field).value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, find_field(field).value)
    end
  end
end

Then /^the "([^"]*)" radio-button(?: within "([^"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      ["true", "checked", true].should include field_checked
    else
      field_checked
    end
  end
end

Then /^the "([^"]*)" radio-button(?: within "([^"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should == nil
    else
      !field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      ["true", true].should include field_checked
    else
      field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      [nil, false].should include field_checked
    else
      !field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  if defined?(Spec::Rails::Matchers)
    URI.parse(current_url).path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), URI.parse(current_url).path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  actual_params   = CGI.parse(URI.parse(current_url).query)
  expected_params = Hash[expected_pairs.rows_hash.map{|k,v| [k,[v]]}]

  if defined?(Spec::Rails::Matchers)
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^I should see the order (.+)$/ do |input|
  current = 0
  input.split(',').each do |match|
    index = page.body.index(match)
    assert index > current, "The index of #{match} was not greater than #{current}"
    current = index
  end
end

Then /^(.+) button is disabled$/ do |text|
  assert !find_button(text).visible?
end

Then /^I should see first (\d+) records in the search results$/ do |arg1|
  assert page.has_content?("Displaying children 1 - 20 ")
end

Then /^"([^"]*)" option should be unavailable to me$/ do |element|
  page.should have_no_xpath("//span[@class='"+element+"']")
end

Then /^password prompt should be enabled$/ do
  assert page.has_content?("Password")
end

When /^I fill in "([^"]*)" in the password prompt$/ do |arg|
  fill_in 'password-prompt-dialog', :with => 'abcd'
end

Then /^Error message should be displayed$/ do
  assert page.has_content?("Enter a valid password")
end

When /^I follow "([^"]*)" for child records$/ do |arg|
  find(:xpath, "//span[@class='export']").click
end

Then /^the message "([^"]*)" should be displayed to me$/ do |text|
  assert page.has_content?("#{text}")
end

Then /^I should be redirected to "([^"]*)" Page$/ do |page_name|
  assert page.has_content?("#{page_name}")
end

Then /^I should see next records in the search results$/ do
  assert page.has_content?("Displaying children 21 - 25 ")
end

Then /^I should see link to "(.*?)"$/ do |text|
  page.should have_xpath("//span[@class='"+text+"']")
end

Then /^I should( not)? be able to view the tab (.+)$/ do|not_visible,tab_name|
  page.has_xpath?("//div[@class='main_bar']//ul/li/a[text()='"+tab_name+"']").should == !not_visible
end