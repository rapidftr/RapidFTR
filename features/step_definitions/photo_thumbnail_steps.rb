require 'spec/spec_helper'
require 'spec/support/matchers/attachment_response'
include CustomMatchers

Then /^I should see the photo of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_resized_photo_path(child, child.primary_photo_id, 328)}
end

Then /^I should see the thumbnail of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_thumbnail_path(child, child.primary_photo_id)}
end

Then /^I should not see the thumbnail of "([^\"]*)"$/ do |child_name|
  check_no_link(response, child_name) {|child| child_thumbnail_path(child, nil)}
end

Then /I should see the photo corresponding to "([^\"]*)"$/ do |photo_file|
  response.should represent_inline_attachment(uploadable_photo(photo_file))
end

Then /^I should see "([^\"]*)" thumbnails$/ do |number|
  thumbnails = current_dom.xpath("//*[@class='thumbnail']/img")
  thumbnails.collect{|element| element['src']}.uniq.size.should eql number.to_i
end

def check_link(response, child_name)
  child = find_child_by_name child_name
  image_link = yield(child)
  response.body.should have_selector("img[src^='#{image_link}']")
end

def check_no_link(response, child_name)
  child = find_child_by_name child_name
  image_link = yield(child)
  response.body.should_not have_selector("img[@src='#{image_link}']")
end

When /^I fill in the basic photo details of a child$/ do
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")
end
