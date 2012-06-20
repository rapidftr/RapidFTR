require 'spec/spec_helper'
require 'spec/support/matchers/attachment_response'
include CustomMatchers

Then /^I should see the photo of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_resized_photo_path(child, child.primary_photo_id, 328)}
end

Then /^I should see the thumbnail of "([^\"]*)"$/ do |child_name|
  check_link(response, child_name) {|child| child_thumbnail_path(child, child.primary_photo_id)}
end

def check_link(response, child_name)
  child = find_child_by_name child_name
  image_link = yield(child)
  page.body.should have_xpath("//img[@src='#{image_link}']")
end
