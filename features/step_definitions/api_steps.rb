
When /^I make a request for (.+)$/ do |resource|
  visit path_to(resource)
end

And /^that JSON list of elements has these properties:$/ do |properties_table|
  
  json_response = JSON.parse(response_body)
  json_response.each do |item|
    item.keys.length.should == properties_table.rows.count
    properties_table.rows.each do |property|
      lambda {item.has_key? property}.should be_true
    end
  end
end

And /^that JSON hash of elements has these properties:$/ do |properties_table|
  
  json_response = JSON.parse(response_body)
  json_response.length.should == properties_table.rows.count
  properties_table.rows.each do |property|
    lambda {json_response.has_key? property}.should be_true
  end
  
end

And /^that JSON response should be composed of items like (.+)$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_response = JSON.parse(response_body)
  json_response.each do |item|
    json_expectation.keys.each do |expectation_key|
      lambda {item.has_key? expectation_key}.should be_true
      lambda {item[expectation_key] == json_expectation[expectation_key] || json_expectation[expectation_key] == "%SOME_STRING%"}.should be_true
    end
  end
end

And /^that JSON response should be composed of items with body$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_response = JSON.parse(response_body)
  json_response.each do |item|
    json_expectation.keys.each do |expectation_key|
      lambda {item.has_key? expectation_key}.should be_true
      lambda {item[expectation_key] == json_expectation[expectation_key] || json_expectation[expectation_key] == "%SOME_STRING%"}.should be_true
    end
  end
end

Then /^I receive a JSON hash$/ do
  json_response = JSON.parse(response_body)
  json_response.class.should == Hash
end

Then /^I receive a JSON array$/ do
  json_response = JSON.parse(response_body)
  json_response.class.should == Array
end

And /^that (.+) should be composed of (.+) elements$/ do |type, num_elements|
  json_response = JSON.parse(response_body)
  json_response.count.should == num_elements.to_i
end

Then /^I receive a JSON hash of (.+) elements$/ do |num_elements|
  json_response = JSON.parse(response_body)
  json_response.class.should == Hash
  json_response.count.should == num_elements.to_i
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

When /^I create the following child:$/ do |table|
	params={}
	params[:format] ||= 'json'
  visit children_path(params), :post, {:child => table.rows_hash}
end

Then /^the following child should be returned:$/ do |table|
  json_response = JSON.parse(response_body)
  table.rows_hash.each do |key,value|
    json_response[key].should == value
  end
end
