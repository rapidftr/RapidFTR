When /^I make a request for (.+)$/ do |resource|
  get api_path_to(resource)
end

Then /^I should receive HTTP (\d+)$/ do |status_code|
  expect(last_response.status).to eq(status_code.to_i)
end

When /^I login as (.+) with password (.+) and imei (.+)$/ do |user, password, imei|

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post(api_login_path, {:imei => imei, :user_name => user, :password => password, :mobile_number => '123456'}.to_json)
end

When /^I send a GET request to "([^\"]*)"$/ do |path|
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get path
end

When /^I send a POST request to "([^\"]*)" with JSON:$/ do |path, body|

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post path, body
end

When /^I send a PUT request to "([^\"]*)" with JSON:$/ do |path, body|
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  put path, body
end

When /^I send a DELETE request to "([^\"]*)"$/ do |path|
  delete path
end

When /^I request the creation of the following unverified user:$/ do |table|
  table.hashes.each do |hash|
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'

    post(register_unverified_users_path,
         {:user =>
              {:user_name => hash['user_name'],
               :full_name => hash['full_name'],
               :organisation => hash['organisation'],
               :unauthenticated_password => hash['password']
              }
         }.to_json)
  end
end

When /^then I logout$/ do
  post(api_logout_path)
end

Then /^an unverified user "(.+)" should be created$/ do |user_name|
  user = User.by_user_name(:key => user_name).first
  expect(user).not_to be_nil
  expect(user.verified).to be false
end

# This is used by the json_spec gem for testing JSON responses
def last_json
  last_response.body
end
