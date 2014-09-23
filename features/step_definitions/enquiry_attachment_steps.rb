When /^I attach an enquiry audio file "([^"]*)"$/ do |audio_path|
  step %(I attach the file "#{audio_path}" to "enquiry[audio]")
end

When /^I attach an enquiry photo "([^"]*)"$/ do |photo_path|
  step %(I attach the file "#{photo_path}" to "enquiry_photo0")
end

Then /^I should see the enquiry photo of "([^\"]*)"$/ do
  enquiry = Enquiry.first
  image_link = resized_photo_path('enquiry', enquiry.id, enquiry.primary_photo_id, 328)
  expect(page.body).to have_css("img[src^='#{image_link}']")
end

When /^the enquiry history should log "([^\"]*)"$/ do |field|
  visit(enquiry_path Enquiry.first.id + '/history')
  expect(page).to have_content(field)
end

When /^I attach the following photos to enquiry:$/ do |table|
  table.raw.each_with_index do |photo, i|
    step %(I attach the file "#{photo.first}" to "enquiry[photo]#{i}")
  end
end
