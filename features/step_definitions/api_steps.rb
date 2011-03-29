
When /^I make a request for (.+)$/ do |resource|
  visit path_to(resource)
end

Then /^I receive a JSON list of elements with Id and Revision$/ do
  json_response = JSON.parse(response_body)
  json_response.class.should == Array
  json_response.each do |item|
    item.keys.length.should == 2
    item.has_key?('id').should be_true
    item.has_key?('rev').should be_true
  end
end

Then /^I receive a JSON response:$/ do |table|
  expected = table.hashes.first
  json_response = JSON.parse(response_body)
  json_response.class.should == Hash
  expected.each {|key,value| json_response[key].should == value}
end

When /^I login with user (.+):(.+) for device with imei (.+)$/ do |user, password, imei|
  post(sessions_path, {:imei => imei, :user_name => user, :password => password, :mobile_number => "123456"})
end

Then /^should_be_successful_login$/ do
  response_body.should_not =~ /sessions\/new/
end

Then /^should_be_unsuccessful_login$/ do
  response_body.should =~ /sessions\/new/
end

