Given /^an? (user|admin) "([^\"]*)" with(?: a)? password "([^\"]*)"$/ do |user_type, username, password|
  user_type = user_type == 'user' ? 'User' : 'Administrator'
  @user = User.new(
    :user_name=>username, 
    :password=>password, 
    :password_confirmation=>password, 
    :user_type=> user_type, 
    :full_name=>username, 
    :email=>"#{username}@test.com")
  @user.save!
end

Given /^an? (user|admin) "([^"]+)"$/ do |user_type, user_name|
  Given %(a #{user_type} "#{user_name}" with password "123")
end

Given /^I am logged in as "(.+)"/ do |user_name|
  session = Session.for_user(User.find_by_user_name(user_name))
  session.save!
  session.put_in_cookie cookies
end

Given /^user "(.+)" is disabled$/ do |username|
  user = User.find_by_user_name(username)
  user.disabled = true
  user.save!
end

Given /^"([^\"]*)" has the following relations:$/ do |child_name, table|
  child = Summary.by_name(:key => child_name).first
  raise "child '#{child_name}' not found" if child.nil?

  relations = table.hashes
  child['relations'] = relations.map do |relation_hash|
    relation_hash['reunite'] = relation_hash['reunite'].downcase.strip == 'yes'
    relation_hash
  end
  child.save!
end


Then /^user "(.+)" should be disabled$/ do |username|
  User.find_by_user_name(username).should be_disabled
end

Then /^user "(.+)" should not be disabled$/ do |username|
  User.find_by_user_name(username).should_not be_disabled
end
