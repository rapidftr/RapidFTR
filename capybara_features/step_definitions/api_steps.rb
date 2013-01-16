
When /^I make a request for (.+)$/ do |resource|
  get api_path_to(resource)
end

Given /^I am sending a session token of "(.*)" in my request headers$/ do |token|
  header "Authorization", "RFTR_Token #{token}"
end

Given /^I am not sending a session token in my request headers$/ do
  header "Authorization", ''
end

Then /^I should have received a "(\d+)" status code$/ do |status_code|
  last_response.status.should == status_code.to_i
end

Then /^The response JSON should contain key "(.+)" with value "(.+)"$/ do |key, value|
  json = JSON.parse(last_response.body)
  json[key].should == value
end

Then /^I receive a JSON response:$/ do |table|
  expected = table.hashes.first
  json_response = JSON.parse(last_response.body)
  json_response.class.should == Hash
  expected.each {|key,value| json_response[key].should == value}
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
  step %Q|I am sending a session token of "#{session.id}" in my request headers|
end

Given /^I am sending a valid session token in my request headers for device with imei "(.+)"$/ do |imei|
  raise "don't know which user I should create a session for" if @user.nil?
  session = Session.for_user(@user, imei)
  session.save!
  step %Q|I am sending a session token of "#{session.id}" in my request headers|
end

When /^I create the following child:$/ do |table|
  params={}
  params[:format] ||= 'json'
  post(children_path(params), {:child => table.rows_hash})
end

When /^I create the following device:$/ do |table|
  params={}
  params[:format] ||= 'json'
  post(devices_path(params), {:device => table.rows_hash})
end

Then /^the following child should be returned:$/ do |table|
  json_response = JSON.parse(last_response.body)
  table.rows_hash.each do |key,value|
    json_response[key].should == value
  end
end

Then /^I receive a JSON hash$/ do
  json_response = JSON.parse(last_response.body)
  json_response.class.should == Hash
end

And /^that (.+) should be composed of (.+) elements$/ do |type, num_elements|
  json_response = JSON.parse(last_response.body)
  json_response.count.should == num_elements.to_i
end

And /^that JSON hash of elements strictly has these properties:$/ do |properties_table|
  json_response = JSON.parse(last_response.body)
  json_response.length.should == properties_table.rows.count
  properties_table.rows.each do |property|
    lambda {json_response.has_key? property}.should be_true
  end
end

Then /^that JSON response should be an item like$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_expectation.keys.each do |expectation_key|
    item_valid(JSON.parse(last_response.body), json_expectation, expectation_key)
  end
end

When /^I edit the following child:$/ do |input_json|
  input_child_hash = JSON.parse(input_json)
  put("/children/" + input_child_hash["_id"], {:child => input_json, :format => 'json'})
end

And /^that JSON hash of elements has these properties:$/ do |properties_table|
  json_response = JSON.parse(last_response.body)
  properties_table.rows.each do |property|
    lambda {json_response.has_key? property}.should be_true
  end
end

And /^that JSON response should be composed of items with body$/ do |json_expectation_string|
  json_expectation = JSON.parse(json_expectation_string)
  json_response = JSON.parse(last_response.body)
  json_response.each do |item|
    json_expectation.keys.each do |expectation_key|
      lambda {item.has_key? expectation_key}.should be_true
      match_value(item[expectation_key], json_expectation[expectation_key])
    end
  end
end

Then /^I receive a JSON array$/ do
  json_response = JSON.parse(last_response.body)
  json_response.class.should == Array
end

When /^I request for child with ID (\d+)$/ do |id|
  get "/children/" + id, {:format => 'json'}
end

Then /^I should get back a response saying null$/ do
  last_response.body.should == "null"
end

When /^I request for the picture of the child with ID (\d+) and square dimensions of (\d+) pixels$/ do |id, dimensions|
  get "/children/"+id+"/resized_photo/" + dimensions, nil
end

def item_valid(item, json_expectation, expectation_key)
  lambda {item.has_key? expectation_key}.should be_true
  match_value(item[expectation_key], json_expectation[expectation_key])
end

def match_value (input, match_text)
  #check simple string match?
  checkval = (input == match_text || match_text == "%SOME_STRING%" )

  #check for boolean?
  checkval = checkval || (match_text == "%SOME_BOOL%" && (input == true || input == false))

  #check for integer?
  checkval = checkval || (match_text == "%SOME_INTEGER%" && !!(input.to_s() =~ /^[-+]?[0-9]+$/))

  #check for fields array?
  checkval = checkval || (match_text == "%SOME_FIELD_ARRAY%" && input.class.should == Array && check_field_array_validity(input))

  #check for field type?
  checkval = checkval || (match_text == "%SOME_FIELD_TYPE%" && (input == "text_field" || input == "select_box" || input == "textarea" || input == "photo_upload_box" || input == "audio_upload_box" || input == "radio_button" || input == "check_boxes" || input == "numeric_field" || input == "date_field"))

  checkval.should be_true
end

def check_field_validity(input_field)
  return_val = true
  return_val = return_val && (input_field.has_key? "name") && match_value(input_field["name"], "%SOME_STRING%")
  return_val = return_val && (input_field.has_key? "visible") && match_value(input_field["visible"], "%SOME_BOOL%")
  return_val = return_val && (input_field.has_key? "type") && match_value(input_field["type"], "%SOME_FIELD_TYPE%")
  if (input_field["type"] == "select_box")
    return_val = return_val && (input_field.has_key? "option_strings_text") && (input_field["option_strings_text"]["en"].class == Array)
  end
  return_val = return_val && (input_field.has_key? "display_name") && match_value(input_field["display_name"]["en"], "%SOME_STRING%")
  return return_val
end

def check_field_array_validity (input_field_array)
  input_field_array.each{|field| if check_field_validity(field) == false then return false end}
  return true
end
