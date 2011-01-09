require 'spec/spec_helper'
require 'spec/support/matchers/attachment_response'
include CustomMatchers

Then /^I should see the photo of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_resized_photo_path(child, 328)}
end

Then /^I should see the thumbnail of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_thumbnail_path(child, nil)}
end

Then /^I should not see the thumbnail of "([^\"]*)"$/ do |child_name|
  check_no_link(response, child_name) {|child| child_thumbnail_path(child, nil)}
end

Then /^I should see the thumbnail of "([^\"]*)" with key "([^\"]*)"$/ do |child_name, photo_key|
  check_link(response, child_name) {|child| child_thumbnail_path(child, photo_key)}
end

Then /I should see the photo corresponding to "([^\"]*)"$/ do |photo_file|
  response.should represent_inline_attachment(uploadable_photo(photo_file))
end

def check_link(response, child_name)
  child = find_child_by_name child_name
  image_link = yield(child)
  response.body.should have_selector("img[@src='#{image_link}']")
end

def check_no_link(response, child_name)
  child = find_child_by_name child_name
  image_link = yield(child)
  response.body.should_not have_selector("img[@src='#{image_link}']")
end
