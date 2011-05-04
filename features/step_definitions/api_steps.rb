
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

Then /^should be kill response for imei "(.+)"$/ do |imei|
  response.status.should =~ /403/
  response_body.should == imei
end

Then /^should be successful login$/ do
  response_body.should_not =~ /sessions\/new/
end

And /^I am using device with imei "(.+)"$/ do |imei|
  session = Session.for_user(@user, nil)
  session.imei = imei
  session.save!
end

