require 'spec_helper'

describe User do

  def build_user( options = {} )
    options.reverse_merge!( {
      :user_name => "user_name_#{rand(10000)}",
      :full_name => 'full name',
      :password => 'password',
      :password_confirmation => options[:password] || 'password',
      :email => 'email@ddress.net',
      :user_type => 'user_type',
      :role_names => options[:role_names] || ['random_role_name'],
    })
    user = User.new( options)
    user
  end

  def build_and_save_user( options = {} )
    user = build_user(options)
    user.save
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

    Clock.stub!(:now).and_return(now)

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

  it "should have error on password_confirmation if no password_confirmation" do
    user = build_user( {
      :password => "timothy",
      :password_confirmation => ""
    })
    user.should_not be_valid
    user.errors[:password_confirmation].should_not be_nil
  end

  it "should localize date using user's timezone" do
    user = build_user({
      :time_zone => "Samoa"
    })
    user.localize_date("2011-11-12 21:22:23 UTC").should == "12 November 2011 at 10:22 (SST)"
  end

  it "should localize date using specified format" do
    user = build_user({
      :time_zone => "UTC"
    })
    user.localize_date("2011-11-12 21:22:23 UTC", "%Y-%m-%d %H:%M:%S (%Z)").should == "2011-11-12 21:22:23 (UTC)"
  end

  it "should load roles only once" do
    role = mock("roles")
    user = build_and_save_user
    Role.should_receive(:by_name).with(:key => user.role_names.first).and_return(role)
    user.roles.should == [role]
    Role.should_not_receive(:get)
    user.roles.should == [role]
  end

  describe "permissions" do
    it "should have limited access" do
      limited_role = Role.create(:name => 'limited', :permissions => Permission::LIMITED)
      user = build_and_save_user(:role_names => [limited_role.name])
      user.limited_access?.should be_true
    end

    it "should not have limited access" do
      access_all = Role.create(:name => "all", :permissions => Permission::ACCESS_ALL_DATA)
      user = build_and_save_user(:role_names => [access_all.name])
      user.limited_access?.should be_false
    end
  end

  describe "#user_assignable?" do
    before { @user = build_user }
    it "role ids should not be assignable" do
      should_not_assignable :role_names
    end
    it "disabled should not be assignable" do
      should_not_assignable :disabled
    end
    def should_not_assignable(name)
      @user.user_assignable?(name => "").should be_false
    end
  end

  describe "user roles" do
    it "should store the roles and retrive them back as Roles" do
      roles = [Role.create!(:name => "Admin", :permissions => [Permission::ADMIN]), Role.create!(:name => "Child Protection Specialist", :permissions => [Permission::ADMIN])]
      user = build_and_save_user(:roles => roles)
      user = User.create({:user_name => "user_123", :full_name => 'full', :password => 'password',:password_confirmation => 'password',:email => 'em@dd.net',:user_type => 'user_type',:permissions => [ "limited" ], :role_names => [roles.first.name, roles.last.name] })
      user = User.find_by_user_name(user.user_name)
      user.roles.should == roles
    end

    it "should require atleast one role" do
      user = build_user(:role_names => [])
      user.should_not be_valid
      user.errors.on(:role_names).should == ["Please select at least one role"]
    end
  end
end
