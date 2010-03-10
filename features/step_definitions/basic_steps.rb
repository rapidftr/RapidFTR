require 'spec/spec_helper'

When /^I fill in the basic details of a child$/ do

  fill_in("Last known location", :with => "Haiti")
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")

end

Then /^I should see the photo of the child$/ do
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty
end

Then /^I should see the photo of the child with a "([^\"]*)" extension$/ do |extension|
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty
end


Given /^I am editing an existing child record$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  raise "Failed to save a valid child record" unless child.save

  visit children_path+"/#{child.id}/edit"
end


Given /^I log in as "([^\"]*)" with password "([^\"]*)"$/ do |arg1, arg2|
    #go to new session 
end

When /^I create a new child$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  child.create!
end
