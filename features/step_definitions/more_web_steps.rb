Given /^I am sending a session token of "(.*)" in my request headers$/ do |token|
  header "Authorization", "RFTR_Token #{token}"
end

Given /^I am not sending a session token in my request headers$/ do
  header "Authorization", ''
  #headers.delete( "Authorization" )
end

Given /^I am sending basic authentication credentials of "([^\"]*)"$/ do |up_pair|
  username,password = up_pair.split("/")
  basic_auth(username,password)
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

Then /^I should be redirected to the (.+)$/ do |page_name|
  response.header["Location"].should == path_to(page_name)
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

