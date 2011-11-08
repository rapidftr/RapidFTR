require 'spec_helper'

describe User do

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
  
  def build_and_save_user( options = {} )
    user = build_user(options)
    user.save
    user
  end

  it 'should be given limited permission unless permission level specified' do
    user = build_user
    user.should be_valid
    user.permission_level.should == PermissionLevel::LIMITED
  end

  it 'should be given unlimited permission if specified' do
    user = build_user(:permission_level => PermissionLevel::UNLIMITED)
    user.should be_valid
    user.permission_level.should == PermissionLevel::UNLIMITED
  end

  it 'validates permission levels' do
    user = build_user(:permission_level => PermissionLevel::UNLIMITED)
    user.should be_valid

    user = build_user(:permission_level => PermissionLevel::LIMITED)
    user.should be_valid

    user = build_user(:permission_level => "any other string")
    user.should_not be_valid
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
    reloaded_user.should_not eql(user)
    reloaded_user.should_not equal(user)
  end
  
  it "can't authenticate which isn't saved" do
    user = build_user(:password => "thepass")
    lambda { user.authenticate("thepass") }.should raise_error
  end

  it "can authenticate with the right password" do
    user = build_and_save_user(:password => "thepass")
    user.authenticate("thepass").should be_true
  end
   
  it "can't authenticate with the wrong password" do
    user = build_and_save_user(:password => "onepassword")
    user.authenticate("otherpassword").should be_false
  end
  
  it "can't authenticate if disabled" do
    user = build_and_save_user(:disabled => "true", :password => "thepass")
    user.authenticate("thepass").should be_false
  end

  it "can't look up password in database" do
    user = build_and_save_user(:disabled => "true", :password => "thepass")
    user.authenticate("thepass").should be_false
  end

  it "can authenticate if not disabled" do
    user = build_and_save_user(:disabled => "false", :password => "thepass")
    user.authenticate("thepass").should be_true
  end

  it "should be able to store a mobile login event" do
    imei = "1337"
    mobile_number = "555-555"
    now = Time.parse("2008-06-21 13:30:00 UTC") 
    user = build_user
    user.create!

    Time.stub(:now).and_return(now)

    user.add_mobile_login_event(imei, mobile_number)
    user.save	
		user = User.get(user.id)

    event = user.mobile_login_history.first
    event[:imei].should == imei
    event[:mobile_number].should == mobile_number
		event[:timestamp].should == now
	end
  
  it "should store list of devices when new device is used" do
    Device.all.each(&:destroy)
    user = build_user
    user.create!
    user.add_mobile_login_event("a imei", "a mobile")
    user.add_mobile_login_event("b imei", "a mobile")
    user.add_mobile_login_event("a imei", "a mobile")

    
    Device.all.map(&:imei).sort().should == (["a imei", "b imei"])
  end
  
  it "should create devices as not blacklisted" do
    Device.all.each(&:destroy)
    
    user = build_user
    user.create!
    user.add_mobile_login_event("an imei", "a mobile")
    
    Device.all.all? {|device| device.blacklisted? }.should be_false
  end
  
  it "should save blacklisted devices to the device list" do
    device = Device.new(:imei => "1234", :blacklisted => false, :user_name => "timothy")
    device.save!
    
    user = build_and_save_user(:user_name => "timothy")
    user.devices = [{"imei" => "1234", "blacklisted" => "true", :user_name => "timothy"}]
    user.save!
    
    blacklisted_device = user.devices.detect { |device| device.imei == "1234" }
    blacklisted_device.blacklisted.should == true
    
  end

end
