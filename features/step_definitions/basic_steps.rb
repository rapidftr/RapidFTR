require 'spec/spec_helper'

When /^I fill in the basic details of a child$/ do
  fill_in("Last known location", :with => "Haiti")
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")
end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  Time.stub!(:now).and_return current_time
end

When /^the local date\/time is "([^\"]*)" and UTC time is "([^\"]*)"$/ do |datetime, utcdatetime|
  current_time = Time.parse(datetime)
  current_time_in_utc = Time.parse(utcdatetime)
  Time.stub!(:now).and_return current_time
  current_time.stub!(:getutc).and_return current_time_in_utc
end

Given /^someone has entered a child with the name "([^\"]*)"$/ do |child_name|
  visit path_to('new child page')
  fill_in('Name', :with => child_name)
  fill_in('Last known location', :with => 'Haiti')
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")
  click_button('Finish')
end

Given /^the following children exist in the system:$/ do |children_table|
  children_table.hashes.each do |child_hash|
    child_hash.reverse_merge!(
            'last_known_location' => 'Cairo',
            'photo_path' => 'features/resources/jorge.jpg',
            'reporter' => 'zubair',
            'age_is' => 'Approximate'
    )

    photo = uploadable_photo(child_hash.delete('photo_path')) if child_hash['photo_path'] != ''
    unique_id = child_hash.delete('unique_id')
    child = Child.new_with_user_name(child_hash['reporter'], child_hash)
    child.photo = photo
    child['unique_identifier'] = unique_id if unique_id
    child.create!
  end
end

Given /^a child record named "([^"]*)" exists with a audio file with the name "([^"]*)"$/ do |name, filename|
  child = Child.new_with_user_name("Bob Creator",{:name=>name})
  child.audio = uploadable_audio("features/resources/#{filename}")
  child.create!
  # visit path_to('new child page')
  #   fill_in('Name', :with => name)
  #   attach_file("child[audio]", "features/resources/#{filename}", "audio/mpeg")
  #   click_button('Save')
end

Then /^I should see "([^\"]*)" in the column "([^\"]*)"$/ do |value, column|

  column_index = -1

  Hpricot(response.body).search("table tr th").each_with_index do |cell, index|
    if (cell.to_plain_text == column )
      column_index = index
    end
  end

  column_index.should be > -1
  rows = Hpricot(response.body).search("table tr")

  match = rows.find do |row|
    cells = row.search("td")
    (cells[column_index] != nil && cells[column_index].to_plain_text == value)
  end

  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the table" unless match
end

Given /^a user "([^\"]*)" has entered a child found in "([^\"]*)" whose name is "([^\"]*)"$/ do |user, location, name|
  new_child_record = Child.new
  new_child_record['last_known_location'] = location
  new_child_record.create_unique_id(user)
  new_child_record['name'] = name
  new_child_record.photo = uploadable_photo("features/resources/jorge.jpg")
  raise "couldn't save a child record!" unless new_child_record.save
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  raise "Failed to save a valid child record" unless child.save

  visit children_path+"/#{child.id}/edit"
end

Given /^an existing child with name "([^\"]*)" and a photo from "([^\"]*)"$/ do |name, photo_file_path|
  child = Child.new( :name => name, :last_known_location => 'unknown' )
  child.photo = uploadable_photo(photo_file_path)
  child.create
end

When /^I am editing the child with name "([^\"]*)"$/ do |name|
  child = find_child_by_name name
  visit children_path+"/#{child.id}/edit"
end

Given /there is a User/ do
  unless @user
    Given "a user \"mary\" with a password \"123\""
  end
end

Given /^there is a admin$/ do
  Given "a admin \"admin\" with a password \"123\""
end

Given /^I am logged in as an admin$/ do
  Given "there is a admin"
  Given "I am on the login page"
  Given "I fill in \"admin\" for \"user name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log In\""
end

Given /^I am logged in$/ do
  Given "there is a User"
  Given "I am on the login page"
  Given "I fill in \"#{User.first.user_name}\" for \"user name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log In\""
end

Given /I am logged out/ do
  Given "I am sending a valid session token in my request headers"
  Given "I go to the logout page"
end

Given /"([^\"]*)" is the user/ do |user_name|
  Given "a user \"#{user_name}\" with a password \"123\""
end  
 
Given /"([^\"]*)" is logged in/ do |user_name|
  Given "\"#{user_name}\" is the user"
  Given "I am on the login page"
  Given "I fill in \"#{user_name}\" for \"user name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log In\""  
end

When /^I create a new child$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  child.create!
end

Given /^a user "([^\"]*)" with a password "([^\"]*)" logs in$/ do |user_name, password|
  Given "a user \"#{user_name}\" with a password \"#{password}\""
  Given "I am on the login page"
  Given "I fill in \"#{user_name}\" for \"user name\""
  Given "I fill in \"#{password}\" for \"password\""
  And  "I press \"Log In\""
end

Given /^there is a child with the name "([^\"]*)" and a photo from "([^\"]*)"$/ do |child_name, photo_file_path|
  child = Child.new( :name => child_name, :last_known_location => 'Chile' )

  child.photo = uploadable_photo(photo_file_path)

  child.create!
end

Then /^I should see the "([^\"]*)" tab$/ do |tab_name|
  tab_names = Hpricot(response.body).child_tab.collect {|item|item.inner_html}
  tab_names.should contain(tab_name)
end

Then /^I should not see the "([^\"]*)" tab$/ do |tab_name|
  tab_names = Hpricot(response.body).child_tab.collect {|item|item.inner_html}
  tab_names.should_not contain(tab_name)
end

Then /^I should not see the "([^\"]*)" tab name in detail section$/ do |tab_name|
  tab_names = Hpricot(response.body).child_tab_name.collect {|item|item.inner_html}
  tab_names.should_not contain(tab_name)
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



Given /^the "([^\"]*)" form section has the field "([^\"]*)" with help text "([^\"]*)"$/ do |form_section, field_name, field_help_text|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :help_text => field_help_text)
  FormSection.add_field_to_formsection(form_section, field)
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" disabled$/ do |form_section, field_name |
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :enabled => false)
  FormSection.add_field_to_formsection(form_section, field)
end


Then /^I should see a (\w+) in the enabled column for the form section "([^\"]*)"$/ do |expected_icon, form_section|
  row = Hpricot(response.body).form_section_row_for form_section
  row.should_not be_nil

  enabled_icon = row.enabled_icon
  enabled_icon["class"].should contain(expected_icon)
end


Then /^I should see the "([^\"]*)" form section link$/ do |form_section_name|
  form_section_names = Hpricot(response.body).form_section_names.collect {|item| item.inner_html}
  form_section_names.should contain(form_section_name)
end

Then /^I should not see the "([^\"]*)" form section link$/ do |form_section_name|
  form_section_names = Hpricot(response.body).form_section_names.collect {|item| item.inner_html}
  form_section_names.should_not contain(form_section_name)
end

Then /^I should see the text "([^\"]*)" in the enabled column for the form section "([^\"]*)"$/ do |expected_text, form_section|
  row = Hpricot(response.body).form_section_row_for form_section
  row.should_not be_nil

  enabled_icon = row.enabled_icon
  enabled_icon.inner_html.strip.should == expected_text
end

Then /^I should see the description text "([^\"]*)" for form section "([^\"]*)"$/ do |expected_description, form_section|
  row = Hpricot(response.body).form_section_row_for form_section
  description_text_cell = row.search("td").detect {|cell| cell.inner_html.strip == expected_description}
  description_text_cell.should_not be_nil
end

Then /^I should see the name "([^\"]*)" for form section "([^\"]*)"$/ do |expected_name, form_section|
  row = Hpricot(response.body).form_section_row_for form_section
  row.search("td")[2].inner_html.strip.should =~ /#{expected_name}/
end


Then /^I should see the form section "([^\"]*)" in row (\d+)$/ do |form_section, expected_row_position|
  row = Hpricot(response.body).form_section_row_for form_section
  rows =  Hpricot(response.body).form_section_rows
  rows[expected_row_position.to_i].inner_html.should == row.inner_html
end

Then /^I should see a current order of "([^\"]*)" for the "([^\"]*)" form section$/ do |expected_order, form_section|
  row = Hpricot(response.body).form_section_row_for form_section
  order_display = row.form_section_order
  order_display.inner_html.strip.should == expected_order
end


Given /^the following suggested fields exist in the system:$/ do |suggested_fields_table|
  suggested_fields_table.hashes.each do |suggested_field_hash|
    suggested_field_hash.reverse_merge!(
            'unique_id'=> suggested_field_hash["name"].gsub(/\s/, "_").downcase)

    field = Field.new :name=> suggested_field_hash["name"],
                      :type=>suggested_field_hash["type"],
                      :help_text => suggested_field_hash["help_text"],
                      :display_name => suggested_field_hash["display_name"],
                      :option_strings=>(eval suggested_field_hash["option_strings"])

    suggested_field_hash[:field] = field
    suggested_field_hash[:is_used] = false
    temp1 = SuggestedField.create!(suggested_field_hash)
  end
end

Then /^I should see the following suggested fields:$/ do |suggested_fields_table|
  suggested_fields_list = Hpricot(response.body).suggested_fields_list
  suggested_fields_list.should_not be_nil
  suggested_fields_table.hashes.each do |suggested_field_hash|
    display = suggested_fields_list.suggested_field_display_for suggested_field_hash[:unique_id]
    display.should_not be_nil
    display.at("input[@name='field[name]']")[:value].strip.should == suggested_field_hash[:name]
    display.inner_html.should contain(suggested_field_hash[:description])
  end
end

Then /^I should not see the following suggested fields:$/ do |suggested_fields_table|
  suggested_fields_list = Hpricot(response.body).suggested_fields_list
  suggested_fields_list.should_not be_nil
  suggested_fields_table.hashes.each do |suggested_field_hash|
    display = suggested_fields_list.suggested_field_display_for suggested_field_hash[:unique_id]
    display.should be_nil
  end
end

And /^I should see "([^\"]*)" in the list of fields$/ do |field_id|
  field_ids = Nokogiri::HTML(response.body).css("table tbody tr").map {|row| row[:id] }
  field_ids.should include("#{field_id}Row")
end



Then /^I should see the text "([^\"]*)" in the list of fields for "([^\"]*)"$/ do |expected_text, field_name |
  field = Hpricot(response.body).form_field_for(field_name)
  field.should_not be_nil

  enabled_icon = field.enabled_icon
  enabled_icon.inner_html.strip.should == expected_text
end

And /^I press add for suggested field "([^\"]*)"$/ do |field_id|
   within(".#{field_id}Display") do
     click_button("Add to form")
   end
end

Then /^"([^\"]*)" should be "([^\"]*)" in "([^\"]*)" table$/ do |row_selector, position, table_selector|
  table = Hpricot(response.body).at(table_selector)
  table.should_not be_nil
  table.at(row_selector).should_not be_nil
  table.search("tbody/tr")[position.to_i-1].should == table.at(row_selector)
end

Then /^I should see the error "([^\"]*)"$/ do |error_message|
  Hpricot(response.body).search("div[@class=errorExplanation]").inner_text.should include error_message
end

Then /^I should not see any errors$/ do
  Hpricot(response.body).search("div[@class=errorExplanation]").size.should == 0
end

Then /^the "([^\"]*)" button presents a confirmation message$/ do |button_name|
  Hpricot(response.body).search("//p[@class=#{button_name.downcase}Button]/a").to_html.should include("confirm")
end

Then /^I should see errors$/ do
  Hpricot(response.body).search("div[@class=errorExplanation]").size.should == 1
end