require 'spec/spec_helper'

When /^I fill in the basic details of a child$/ do
  fill_in("Birthplace", :with => "Haiti")
  attach_file("child[photo]0", "features/resources/jorge.jpg")
end

When /^I attach a photo "([^"]*)"$/ do |photo_path|
  steps %Q{
    When I attach the file "#{photo_path}" to "child[photo]0"
  }
end

When /^I attach an audio file "([^"]*)"$/ do |audio_path|
  steps %Q{
    When I attach the file "#{audio_path}" to "child[audio]"
  }
end

When /^I attach the following photos:$/ do |table|
  table.raw.each_with_index do |photo, i|
    steps %Q{
      When I attach the file "#{photo}" to "child[photo]#{i}"
    }
  end
end

Given /^the following form sections exist in the system:$/ do |form_sections_table|
  FormSection.all.each {|u| u.destroy }

  form_sections_table.hashes.each do |form_section_hash|
    form_section_hash.reverse_merge!(
      'unique_id'=> form_section_hash["name"].gsub(/\s/, "_").downcase,
      'enabled' => true,
      'fields'=> Array.new
    )

    form_section_hash["order"] = form_section_hash["order"].to_i
    FormSection.create!(form_section_hash)
  end
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" with field type "([^\"]*)"$/ do |form_section, field_name, field_type|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :type => field_type)
  FormSection.add_field_to_formsection(form_section, field)
end

Given /^the following fields exists on "([^"]*)":$/ do |form_section_name, table|
  form_section = FormSection.get_by_unique_id(form_section_name)
  form_section.should_not be_nil
  form_section.fields = []
  table.hashes.each do |field_hash|
    field_hash.reverse_merge!(
      'enabled' => true,
      'type'=> Field::TEXT_FIELD
    )
    form_section.fields.push Field.new(field_hash)
  end
  form_section.save!
end

Then /^there should be (\d+) child records in the database$/ do |number_of_records|
  Child.all.length.should == number_of_records.to_i
end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  current_time.stub!(:getutc).and_return Time.parse(datetime)
  Clock.stub!(:now).and_return current_time
end

When /^the local date\/time is "([^\"]*)" and UTC time is "([^\"]*)"$/ do |datetime, utcdatetime|
  current_time = Time.parse(datetime)
  current_time_in_utc = Time.parse(utcdatetime)
  Clock.stub!(:now).and_return current_time
  current_time.stub!(:getutc).and_return current_time_in_utc
end

Given /^a child record named "([^"]*)" exists with a audio file with the name "([^"]*)"$/ do |name, filename|
  child = Child.new_with_user_name("Bob Creator",{:name=>name})
  child.audio = uploadable_audio("features/resources/#{filename}")
  child.create!
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child["birthplace"] = "haiti"
  child.photo = uploadable_photo
  raise "Failed to save a valid child record" unless child.save

  visit children_path+"/#{child.id}/edit"
end

Given /^an existing child with name "([^\"]*)" and a photo from "([^\"]*)"$/ do |name, photo_file_path|
  child = Child.new( :name => name, :birthplace => 'unknown' )
  child.photo = uploadable_photo(photo_file_path)
  child.create
end

When /^I am editing the child with name "([^\"]*)"$/ do |name|
  child = find_child_by_name name
  visit children_path+"/#{child.id}/edit"
end

When /^I wait for (\d+) seconds$/ do |seconds|
  sleep seconds.to_i
end

Then /^I should see (\d*) divs of class "(.*)"$/ do |quantity, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
end

Then /^I should see (\d*) divs with text "(.*)" for class "(.*)"$/ do |quantity, div_text, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
  divs.each do |div|
    div.text.should == div_text
  end
end

Then /^the "([^\"]*)" button presents a confirmation message$/ do |button_name|
  page.find("//p[@class='#{button_name.downcase}Button']/a")['data-confirm'].should_not be_nil
end

Given /^I flag "([^\"]*)" as suspect$/ do  |name|
  click_flag_as_suspect_record_link_for(name)
  click_button("Flag")
end

When /^I flag "([^\"]*)" as suspect with the following reason:$/ do |name, reason|
  click_flag_as_suspect_record_link_for(name)
  fill_in("Flag Reason", :with => reason)
  click_button("Flag")
end

When /^I unflag "([^\"]*)" with the following reason:$/ do |name, reason|
  child = find_child_by_name name
  visit children_path+"/#{child.id}"
  click_link("Unflag record")
  fill_in("Unflag Reason", :with => reason)
  click_button("Unflag")
end

Then /^the (view|edit) record page should show the record is flagged$/ do |page_type|
  path = children_path+"/#{Child.all[0].id}"
  (page_type == "edit") ? visit(path + "/edit") : visit(path)
  page.should have_content("Flagged as suspect record by")
end

Then /^the child listing page filtered by flagged should show the following children:$/ do |table|
  expected_child_names = table.raw.flatten
  visit child_filter_path("flagged")
  child_records = Hpricot(page.body).search("div[@class=profiles-list-item] h3 a").map {|a| a.inner_text }
  child_records.should == expected_child_names
end

When /^the record history should log "([^\"]*)"$/ do |field|
  visit(children_path+"/#{Child.all[0].id}/history")
  page.should have_content(field)
end

Then /^I should (not )?see the "([^\"]*)" tab$/ do |do_not_want, tab_name|
  should = do_not_want ? :should_not : :should
  page.all(:css, ".tab-handles a").map(&:text).send(should, include(tab_name))
end

When /^I sleep (\d*) seconds$/ do |sleep_time|
  sleep sleep_time.to_i
end

Given /"([^\"]*)" is logged in/ do |user_name|
  Given "\"#{user_name}\" is the user"
  Given "I am on the login page"
  Given "I fill in \"#{user_name}\" for \"User name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log in\""
end

Given /"([^\"]*)" is the user/ do |user_name|
  Given "a user \"#{user_name}\" with a password \"123\""
end

Then /^I should not see any errors$/ do
  Hpricot(page.body).search("div[@class=errorExplanation]").size.should == 0
end

Then /^I should see the error "([^\"]*)"$/ do |error_message|
  Hpricot(page.body).search("div[@class=errorExplanation]").inner_text.should include error_message
end

Then /^the "([^\"]*)" result should have a "([^\"]*)" image$/ do |name, image|
  child_name = find_child_by_name name
  child_images = Hpricot(page.body).search("#child_#{child_name.id}]").search("img[@class='flag']")
  child_images[0][:src].should have_content(image)
end

Given /I am logged out/ do
  Given "I go to the logout page"
end

Then /^the "([^"]*)" dropdown should have "([^"]*)" selected$/ do |dropdown_label, selected_text|
  field_labeled(dropdown_label).value.should == selected_text
end

Then /^I should not see any errors$/ do
  Hpricot(page.body).search("div[@class=errorExplanation]").size.should == 0
end

Then /^I should see the error "([^\"]*)"$/ do |error_message|
  Hpricot(page.body).search("div[@class=errorExplanation]").inner_text.should include error_message
end

Then /^the "([^\"]*)" result should have a "([^\"]*)" image$/ do |name, image|
  child_name = find_child_by_name name
  child_images = Hpricot(page.body).search("#child_#{child_name.id}]").search("img[@class='flag']")
  child_images[0][:src].should have_content(image)
end

private

def click_flag_as_suspect_record_link_for(name)
  child = find_child_by_name name
  visit children_path+"/#{child.id}"
  click_link("Flag as suspect record")
end
