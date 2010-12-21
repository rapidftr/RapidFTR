
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

