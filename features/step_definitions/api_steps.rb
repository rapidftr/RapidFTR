
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

And /^that JSON hash of elements strictly has these properties:$/ do |properties_table|
  
  json_response = JSON.parse(response_body)
  json_response.length.should == properties_table.rows.count
  properties_table.rows.each do |property|
    lambda {json_response.has_key? property}.should be_true
  end
  
end

And /^that JSON hash of elements has these properties:$/ do |properties_table|
  
  json_response = JSON.parse(response_body)
  properties_table.rows.each do |property|
    lambda {json_response.has_key? property}.should be_true
  end
  
end

And /^that JSON response should be composed of items like (.+)$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_response = JSON.parse(response_body)
  json_response.each do |item|
    json_expectation.keys.each do |expectation_key|
      item_valid(item, json_expectation, expectation_key)
    end
  end
end

Then /^that JSON response should be an item like$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_expectation.keys.each do |expectation_key|
    item_valid(JSON.parse(response_body), json_expectation, expectation_key)
  end
end

def item_valid(item, json_expectation, expectation_key)
  lambda {item.has_key? expectation_key}.should be_true
  match_value(item[expectation_key], json_expectation[expectation_key])
end

And /^that JSON response should be composed of items with body$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_response = JSON.parse(response_body)
  json_response.each do |item|
    json_expectation.keys.each do |expectation_key|
      lambda {item.has_key? expectation_key}.should be_true
      match_value(item[expectation_key], json_expectation[expectation_key])
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
  post(sessions_path, {:imei => imei, :user_name => user, :password => password, :mobile_number => "123456", :format => 'json'})
end

def check_field_validity(input_field)
  return_val = true
  return_val = return_val && (input_field.has_key? "name") && match_value(input_field["name"], "%SOME_STRING%")
  return_val = return_val && (input_field.has_key? "visible") && match_value(input_field["visible"], "%SOME_BOOL%")
  return_val = return_val && (input_field.has_key? "editable") && match_value(input_field["editable"], "%SOME_BOOL%")
  return_val = return_val && (input_field.has_key? "type") && match_value(input_field["type"], "%SOME_FIELD_TYPE%")
  if (input_field["type"] == "select_box")
    return_val = return_val && (input_field.has_key? "option_strings") && (input_field["option_strings"].class == Array)
  end
  return_val = return_val && (input_field.has_key? "display_name") && match_value(input_field["display_name"], "%SOME_STRING%")
  return return_val
end

def check_field_array_validity (input_field_array)
  input_field_array.each{|field| if check_field_validity(field) == false then return false end}
  return true
end

def match_value (input, match_text)
#  puts input
#  puts match_text
  #check simple string match?
  checkval = (input == match_text || match_text == "%SOME_STRING%" )

  #check for boolean?
  checkval = checkval || (match_text == "%SOME_BOOL%" && (input == true || input == false))

  #check for integer?
  checkval = checkval || (match_text == "%SOME_INTEGER%" && !!(input.to_s() =~ /^[-+]?[0-9]+$/))

  #check for fields array?
  checkval = checkval || (match_text == "%SOME_FIELD_ARRAY%" && input.class.should == Array && check_field_array_validity(input))

  #check for field type?
  checkval = checkval || (match_text == "%SOME_FIELD_TYPE%" && (input == "text_field" || input == "select_box" || input == "textarea" || input == "photo_upload_box" || input == "audio_upload_box" || input == "radio_button" || input == "check_box" || input == "numeric_field" || input == "date_field"))

  checkval.should be_true

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

When /^I edit the following child:$/ do |input_json|
  input_child_hash = JSON.parse(input_json)
  visit "/children/" + input_child_hash["_id"], :put, {:child => input_child_hash, :format => 'json'}
end

When /^I request for child with ID (\d+)$/ do |id|
  visit "/children/" + id, :get, {:format => 'json'}
end

Then /^I should get back a response saying null$/ do
  response_body.should == "null"
end

Then /^the following child should be returned:$/ do |table|
  json_response = JSON.parse(response_body)
  table.rows_hash.each do |key,value|
    json_response[key].should == value
  end
end

When /^I request for the picture of the child with ID (\d+) and square dimensions of (\d+) pixels$/ do |id, dimensions|
  visit "/children/"+id+"/resized_photo/" + dimensions, :get, nil
end
