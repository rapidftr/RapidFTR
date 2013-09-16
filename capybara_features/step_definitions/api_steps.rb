When /^I make a request for (.+)$/ do |resource|
  get api_path_to(resource)
end

Then /^I should receive HTTP (\d+)$/ do |status_code|
  last_response.status.should == status_code.to_i
end

When /^I login as (.+) with password (.+) and imei (.+)$/ do |user, password, imei|
  post(api_login_path, {:imei => imei, :user_name => user, :password => password, :mobile_number => "123456", :format => 'json'})
end

When /^I send a GET request to "([^\"]*)"$/ do |path|
  get path
end

When /^I send a POST request to "([^\"]*)" with JSON:$/ do |path, body|
  begin
    post path, JSON.parse(body)
  rescue JSON::ParserError => e
    post path, body
  end
end

When /^I send a PUT request to "([^\"]*)" with JSON:$/ do |path, body|
  put path, JSON.parse(body)
end

When /^I send a DELETE request to "([^\"]*)"$/ do |path|
  delete path
end

When /^I request the creation of the following unverified user:$/ do |table|
  table.hashes.each do |hash|
    post(register_unverified_user_path,
      {:format => 'json', :user =>
        {:user_name => hash["user_name"],
        :full_name => hash["full_name"],
        :organisation => hash["organisation"],
        :unauthenticated_password => hash["password"]
      }})
  end
end

Then /^an unverified user "(.+)" should be created$/ do |user_name|
  user = User.by_user_name(:key => user_name).first
  user.should_not be_nil
  user.verified.should be_false
end

# This is used by the json_spec gem for testing JSON responses
def last_json
  last_response.body
end
