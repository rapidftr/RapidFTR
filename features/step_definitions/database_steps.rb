Given /^a user "([^\"]*)" with a password "([^\"]*)"$/ do |username, password|
 @user = User.new(:user_name=>username, :password=>password, :password_confirmation=>password, :user_type=>"Administrator", :full_name=>username, :email=>"#{username}@test.com")
 @user.save!
end
