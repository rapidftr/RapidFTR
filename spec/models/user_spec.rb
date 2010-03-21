require 'spec_helper'

describe User do

  before :each do
  end

  def build_user( options = {} )
    options.reverse_merge!( {
      :user_name => "user_name_#{rand(10000)}",
      :full_name => 'full name',
      :password => 'password',
      :password_confirmation => options[:password] || 'password',
      :email => 'email@ddress.net',
      :user_type => 'user_type'
    })
    user = User.new( options) 
    user
  end

  it 'should validate uniqueness of username for new users' do
    user = build_user(:user_name => 'the_user_name')
    user.should be_valid
    user.create!
    
    dupe_user = build_user(:user_name => 'the_user_name')
    dupe_user.should_not be_valid
  end

  it 'should consider a re-loaded user as valid' do
    user = build_user
    raise user.errors.full_messages.inspect unless user.valid?
    user.create!

    reloaded_user = User.get( user.id )
    raise reloaded_user.errors.full_messages.inspect unless reloaded_user.valid?
    reloaded_user.should be_valid
  end

  it "should reject saving a changed password if the confirmation doesn't match" do
    user = build_user
    user.create!
    user.password = 'foo'
    user.password_confirmation = 'not foo'
    user.should_not be_valid
  end

  it "should allow password update if confirmation matches" do
    user = build_user
    user.create!
    user.password = 'new_password'
    user.password_confirmation = 'new_password'

    user.should be_valid
  end

  it "doesn't use _id for equality" do
    user = build_user
    user.create!

    reloaded_user = User.get( user.id )

    reloaded_user.should_not == user
    reloaded_user.should_not eql user
    reloaded_user.should_not equal user
  end
  
  it "can authenticate with the right password" do
    user = build_user(:password => "thepass")
    user.authenticate("thepass").should be_true
  end
  
  it "can't authenticate with the wrong password" do
    user = build_user(:password => "onepassword")
    user.authenticate("otherpassword").should be_false
  end
  
  it "can't authenticate if disabled" do
    user = build_user(:disabled => true, :password => "thepass")
    user.authenticate("thepass").should be_false
  end

end
