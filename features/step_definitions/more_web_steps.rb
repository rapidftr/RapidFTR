Given /^I am sending a session token of "(.*)" in my request headers$/ do |token|
  header "Authorization", "RFTR_Token #{token}"
end

Given /^I am not sending a session token in my request headers$/ do
  header "Authorization", ''
  #headers.delete( "Authorization" )
end

Given /^I am sending a valid session token in my request headers$/ do
  raise "don't know which user I should create a session for" if @user.nil?
  session = Session.for_user(@user)
  session.save!
  Given %Q|I am sending a session token of "#{session.id}" in my request headers|
end

Then /^(?:|I )should see a link to the (.+)$/ do |page_name|
  response_body.should have_selector("a[href='#{path_to(page_name)}']")
end

Then /^I should see an image from the (.+)$/ do |image_resource_name|
  response_body.should have_selector("img[src='#{path_to(image_resource_name)}']")
end

Then /^I should not see an image from the (.+)$/ do |image_resource_name|
  response_body.should_not have_selector("img[src='#{path_to(image_resource_name)}']")
end

Then /^show me the cookies$/ do
  puts "COOKIES:"
  puts cookies.inspect
end

Then /^I should have received a "(.+)" status code$/ do |status_code|
  response.status.should == status_code
end

Then /^I should find the following links:$/ do |table|
  table.rows_hash.each do |label, named_path|
    href = path_to(named_path)
    assert_have_xpath "//a[@href='#{href}' and text()='#{label}']"
  end
end

Then /^I should find the form with following attributes:$/ do |table|
  table.raw.each do |attribute|
    assert_contain attribute.first
  end
end

Then /^the "([^\"]*)" field should be disabled$/ do |label|
  field_labeled(label).should be_disabled
end

Then /^I should see the select named "([^\"]*)"$/ do |select_name|
  	response_body.should have_selector("select[name='#{select_name}']")
end

Then /^I should see an option "([^\"]*)" for select "([^\"]*)"$/  do | option_value, select_name|
  	response_body.should have_selector("select[name='#{select_name}'] option[value=#{option_value}]")
end

Then /^I should not be able to see (.+)$/ do |page_name|
  lambda { visit path_to(page_name) }.should raise_error(AuthorizationFailure)
end
