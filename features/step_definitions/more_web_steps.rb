Then /^(?:|I )should see a link to the (.+)$/ do |page_name|
  response_body.should have_selector("a[href='#{path_to(page_name)}']")   
end

Then /^I should see an image from the (.+)$/ do |image_resource_name|
  response_body.should have_selector("img[src='#{path_to(image_resource_name)}']")
end

Then /^I should not see an image from the (.+)$/ do |image_resource_name|
  response_body.should_not have_selector("img[src='#{path_to(image_resource_name)}']")
end
