
When /^I make a request for (.+)$/ do |resource|
  get api_path_to(resource)
end

Given /^I am sending a session token of "(.*)" in my request headers$/ do |token|
  header "Authorization", "RFTR_Token #{token}"
end

Given /^I am not sending a session token in my request headers$/ do
  header "Authorization", ''
  #headers.delete( "Authorization" )
end

Then /^I should have received a "(\d+)" status code$/ do |status_code|
  last_response.status.should == status_code.to_i
end

Then /^The response JSON should contain key "(.+)" with value "(.+)"$/ do |key, value|
  json = JSON.parse(last_response.body)
  json[key].should == value
end

When /^I login with user (.+):(.+) for device with imei (.+)$/ do |user, password, imei|
  post(sessions_path, {:imei => imei, :user_name => user, :password => password, :mobile_number => "123456", :format => 'json'})
end

Then /^should be kill response for imei "(.+)"$/ do |imei|
  last_response.status.should == 403
  last_response.body.should == imei
end

Then /^should be successful login$/ do
  last_response.body.should_not =~ /sessions\/new/
end

#Given /I am logged out/ do
#  Given "I am sending a valid session token in my request headers"
#  Given "I go to the logout page"
#end

Given /^I am sending a valid session token in my request headers$/ do
  raise "don't know which user I should create a session for" if @user.nil?
  session = Session.for_user(@user, nil)
  session.save!
  Given %Q|I am sending a session token of "#{session.id}" in my request headers|
end

Given /^I am sending a valid session token in my request headers for device with imei "(.+)"$/ do |imei|
  raise "don't know which user I should create a session for" if @user.nil?
  session = Session.for_user(@user, imei)
  session.save!
  Given %Q|I am sending a session token of "#{session.id}" in my request headers|
end
