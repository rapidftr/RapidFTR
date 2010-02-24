require 'spec/spec_helper'

When /^I fill in the basic details of a child$/ do

  fill_in("Last known location", :with => "Haiti")
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")

end

Given /^someone has entered a child with the name "([^\"]*)"$/ do |child_name|
  visit path_to('new child page')
  fill_in('Name', :with => child_name)
  fill_in('Last known location', :with => 'Haiti')
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")
  click_button('Create')
end

Then /^I should see "([^\"]*)" in the column "([^\"]*)"$/ do |value, column|

  column_index = -1

  Hpricot(response.body).search("table th td").each_with_index do |cell, index|
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

Then /^I should see the photo of the child$/ do
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty  
end

Then /^I should see the photo of the child with a "([^\"]*)" extension$/ do |extension|
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty
end

Given /^a user "([^\"]*)" has entered a child found in "([^\"]*)" whose name is "([^\"]*)"$/ do |user, location, name|
  new_child_record = Child.new
  new_child_record['last_known_location'] = location
  new_child_record.create_unique_id(user)
  new_child_record['name'] = name
  photo_file = File.new("features/resources/jorge.jpg")
  def photo_file.content_type
    "image/jpg"
  end
  def photo_file.original_path
   "features/resources/jorge.jpg"
  end
  new_child_record.photo = photo_file
  raise "couldn't save a child record!" unless new_child_record.save
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  raise "Failed to save a valid child record" unless child.save

  visit children_path+"/#{child.id}/edit"
end