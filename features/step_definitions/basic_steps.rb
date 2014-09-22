When /^I fill in the basic details of a child$/ do
  fill_in('Birthplace', :with => 'Haiti')
end

When /^I attach a photo "([^"]*)"$/ do |photo_path|
  step %(I attach the file "#{photo_path}" to "child_photo0")
end

When /^I attach an audio file "([^"]*)"$/ do |audio_path|
  step %(I attach the file "#{audio_path}" to "child[audio]")
end

When /^I attach the following photos:$/ do |table|
  table.raw.each_with_index do |photo, i|
    step %(I attach the file "#{photo.first}" to "child[photo]#{i}")
  end
end

Given /^no forms exist in the system$/ do
  FormSection.all.each { |u| u.destroy }
  Form.all.each { |f| f.destroy }
end

Given /^the following forms exist in the system:$/ do |forms_table|
  forms_table.hashes.each do |form_hash|
    form_hash.reverse_merge!('unique_id' => form_hash['name'].gsub(/\s/, '_').downcase)
    destroy_form(form_hash['name'])
    form = Form.new(form_hash)
    form.save!
  end
end

Given /^the following form sections exist in the system on the "(.*)" form:$/ do |form_name, form_sections_table|
  destroy_form(form_name)

  form = Form.create(:name => form_name)
  form_sections_table.hashes.each do |form_section_hash|
    form_section_hash.reverse_merge!(
      'unique_id' => form_section_hash['name'].gsub(/\s/, '_').downcase,
      'fields' => Array.new,
      'form' => form
    )

    form_section_hash['order'] = form_section_hash['order'].to_i
    form_section = FormSection.new(form_section_hash)
    form_section.save!
  end
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" with field type "([^\"]*)"$/ do |form_section, field_name, field_type|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, '_'))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :type => field_type)
  FormSection.add_field_to_form_section(form_section, field)
end

Given /^the following fields exists on "([^"]*)":$/ do |form_section_name, table|
  form_section = FormSection.get_by_unique_id(form_section_name)
  expect(form_section).not_to be_nil
  form_section.fields = []
  table.hashes.each do |field_hash|
    field_hash.reverse_merge!(
      'visible' => true,
      'type' => Field::TEXT_FIELD
    )
    form_section.fields.push FactoryGirl.build(:field, field_hash)
  end

  form_section.save!
end

Then /^there should be (\d+) child records in the database$/ do |number_of_records|
  expect(Child.all.length).to eq(number_of_records.to_i)
end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  current_time.stub(:getutc).and_return Time.parse(datetime)
  Clock.stub(:now).and_return current_time
end

When /^the local date\/time is "([^\"]*)" and UTC time is "([^\"]*)"$/ do |datetime, utcdatetime|
  current_time = Time.parse(datetime)
  current_time_in_utc = Time.parse(utcdatetime)
  Clock.stub(:now).and_return current_time
  current_time.stub(:getutc).and_return current_time_in_utc
end

Given /^a child record named "([^"]*)" exists with a audio file with the name "([^"]*)"$/ do |name, filename|
  user = User.create!('user_name' => 'bob_creator',
                      'password' => 'rapidftr',
                      'password_confirmation' => 'rapidftr',
                      'full_name' => 'Bob Creator',
                      'organisation' => 'UNICEF',
                      'email' => 'rapidftr@rapidftr.com',
                      'disabled' => 'false',
                      'role_ids' => ['ADMIN'])
  child = Child.new_with_user_name(user, :name => name)
  child.audio = uploadable_audio("features/resources/#{filename}")
  child.create!
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child[:created_by] = 'mary'
  child['birthplace'] = 'haiti'
  child.photo = uploadable_photo
  child['unique_identifier'] = 'UNIQUE_IDENTIFIER'
  fail 'Failed to save a valid child record' unless child.save

  visit children_path + "/#{child.id}/edit"
end

Given /^an existing child with name "([^\"]*)" and a photo from "([^\"]*)"$/ do |name, photo_file_path|
  child = Child.new(:name => name, :birthplace => 'unknown', :created_by => 'mary')
  child.photo = uploadable_photo(photo_file_path)
  child.create
end

When /^I am editing the child with name "([^\"]*)"$/ do |name|
  child = find_child_by_name name
  visit children_path + "/#{child.id}/edit"
end

When /^I wait for (\d+) seconds$/ do |seconds|
  sleep seconds.to_i
end

When 'I wait for the page to load' do
  if Capybara.current_driver == :selenium
    Timeout.timeout(Capybara.default_wait_time) do
      sleep(0.1) until page.evaluate_script('window["jQuery"] != undefined && window["jQuery"] != null && jQuery.active == 0')
    end
  else
    page.has_content? ''
  end
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_content?(selector)
end

Then /^I should see (\d*) divs of class "(.*)"$/ do |quantity, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  expect(divs.size).to eq(quantity.to_i)
end

Then /^I should see (\d*) divs with text "(.*)" for class "(.*)"$/ do |quantity, div_text, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  expect(divs.size).to eq(quantity.to_i)
  divs.each do |div|
    expect(div.text).to eq(div_text)
  end
end

Then /^the "([^\"]*)" button presents a confirmation message$/ do |button_name|
  expect(page.find("//a[@class='link_#{button_name.downcase}']")['data-confirm']).not_to be_nil
end

Given /^I flag "([^\"]*)" as suspect$/ do  |name|
  click_flag_as_suspect_record_link_for(name)
  fill_in('Flag Reason', :with => 'Test')
  click_button('Flag')
end

When /^I flag "([^\"]*)" as suspect with the following reason:$/ do |name, reason|
  page.find(:xpath, "//div[text()=\"#{name}\"]/parent::*/parent::*/parent::*").click_link('Flag record')
  fill_in('Flag Reason:', :with => reason)
  click_button('Flag')
end

When /^I flag as suspect with the following reason:$/ do |reason|
  click_link('Flag record')
  fill_in('Flag Reason:', :with => reason)
  click_button('Flag')
end

When /^I unflag "([^\"]*)" with the following reason:$/ do |name, reason|
  click_flag_as_suspect_record_link_for(name)
  fill_in('Unflag Reason', :with => reason)
  click_button('Unflag')
end

Then /^the (view|edit) record page should show the record is flagged$/ do |page_type|
  path = children_path + "/#{Child.first.id}"
  (page_type == 'edit') ? visit(path + '/edit') : visit(path)
  expect(page).to have_content('Flagged as suspect record by')
end

Then /^the child listing page filtered by flag should show the following children:$/ do |table|
  expected_child_names = table.raw.flatten
  visit child_filter_path(:filter => 'flag')
  expected_child_names.each do |name|
    expect(page).to have_xpath "//h2//a[contains(., '#{name}')]"
  end
end

When /^the record history should log "([^\"]*)"$/ do |field|
  visit(children_path + "/#{Child.first.id}/history")
  expect(page).to have_content(field)
end

Then /^I should (not )?see the "([^\"]*)" tab$/ do |do_not_want, tab_name|
  should = do_not_want ? :should_not : :should
  page.all(:css, '.tab-handles a').map(&:text).send(should, include(tab_name))
end

When /^I sleep (\d*) seconds$/ do |sleep_time|
  sleep sleep_time.to_i
end

Given /"([^\"]*)" is logged in/ do |user_name|
  step "\"#{user_name}\" is the user"
  step 'I am on the login page'
  step "I fill in \"User Name\" with \"#{user_name}\""
  step "I fill in \"123\" for \"password\""
  step "I press \"Log in\""
end

Given /"([^\"]*)" is the user/ do |user_name|
  step "a user \"#{user_name}\" with a password \"123\" and \"Access all data\" permission"
end

Then /^I should not see any errors$/ do
  expect(page).not_to have_xpath '//div[class="errorExplanation"]'
end

Then /^I should see the error "([^\"]*)"$/ do |error_message|
  expect(page).to have_xpath "//div[@class=errorExplanation and contains(., '#{error_message}')]"
end

Then /^the "([^\"]*)" result should have a "([^\"]*)" image$/ do |name, flag|
  child_name = find_child_by_name name
  expect(page).to have_css "#child_#{child_name.id} .#{flag}"
end

Given /I am logged out/ do
  step 'I am on the logout page'
end

Then /^the "([^"]*)" dropdown should have "([^"]*)" selected$/ do |dropdown_label, selected_text|
  expect(field_labeled(dropdown_label).value).to eq(selected_text)
end

And /^I should see "([^\"]*)" in the list of fields$/ do |field_name|
  expect(page).to have_xpath("//table[@id='form_sections']//tr[@class='rowEnabled' and contains(., '#{field_name}')]")
end

And /^I should see "([^\"]*)" in the list of fields and disabled$/ do |field_name|
  expect(page).to have_xpath("//table[@id='form_sections']//tr[@class='rowDisabled' and contains(., '#{field_name}')]")
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" with help text "([^\"]*)"$/ do |form_section, field_name, field_help_text|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, '_'))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :help_text => field_help_text)
  FormSection.add_field_to_form_section(form_section, field)
end

Then /^I should see the text "([^\"]*)" in the list of fields for "([^\"]*)"$/ do |expected_text, field_name |
  # This selector is no longer working, need to find some other selector for searching field
  field = page.find "//div[@id='#{field_name}Row']"
  expect(field).not_to be_nil

  enabled_icon = field.enabled_icon
  expect(enabled_icon.inner_html.strip).to eq(expected_text)
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" hidden$/ do |form_section, field_name |
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, '_'))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :visible => false)
  FormSection.add_field_to_form_section(form_section, field)
end

Then /^I should see errors$/ do
  expect(page).to have_xpath '//div[@class="errorExplanation"]'
end

When /^I debug$/ do
  require 'pry'
  binding.pry # rubocop:disable Debugger
end

private

def click_flag_as_suspect_record_link_for(name)
  child = find_child_by_name name
  visit children_path + "/#{child.id}"
  find(:css, '.btn_flag').click
end

def destroy_form(form_name)
  form = Form.find_by_name(form_name)
  form.sections.each { |section| section.destroy } unless form.nil?
  form.destroy unless form.nil?
end

Given(/^the following system variables exist in the system$/) do |table|
  # table is a table.hashes.keys # => [:name, :value]
  table.hashes.each do | system_variables_hash|
    SystemVariable.create(:name => system_variables_hash['name'], :value => system_variables_hash['value'])
  end
end
