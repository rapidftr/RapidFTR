require 'spec_helper'

describe User do

  def build_user(options = {})
    options.reverse_merge!({
                               :user_name => "user_name_#{rand(10000)}",
                               :full_name => 'full name',
                               :password => 'password',
                               :password_confirmation => options[:password] || 'password',
                               :email => 'email@ddress.net',
                               :user_type => 'user_type',
                               :organisation => 'TW',
                               :disabled => 'false',
                               :role_ids => options[:role_ids] || ['random_role_id'],
                           })
    user = User.new(options)
    user
  end

  def build_and_save_user(options = {})
    user = build_user(options)
    user.save
    user
  end

  describe "validations" do

    it "should not be valid when username contains whitespace" do
      user = build_user :user_name => "in val id"
      user.should_not be_valid
      user.errors.on(:user_name).should == ["Please enter a valid user name"]
    end

    it "should be valid when password contains whitespace" do
      user = build_user :password => "valid with spaces"
      user.should be_valid
    end

    it "should not be valid when username already exists" do
      build_and_save_user :user_name => "existing_user"
      user = build_user :user_name => "existing_user"
      user.should_not be_valid
      user.errors.on(:user_name).should == ["User name has already been taken! Please select a new User name"]
    end

    it "should not be valid when email address is invalid" do
      user = build_user :email => "invalid_email"
      user.should_not be_valid
      user.errors.on(:email).should == ["Please enter a valid email address"]
    end

    it "should throw error if organisation detail not entered" do
      user = build_user :organisation => nil
      user.should_not be_valid
      user.errors.on(:organisation).should == ["Please enter the user's organisation name"]
      end

    it "should throw error if disabled field is not set" do
      user = build_user :disabled => nil
      user.should_not be_valid
      user.errors.on(:disabled).should == ["Disabled attribute is required."]
    end
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

    reloaded_user = User.get(user.id)
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

    reloaded_user = User.get(user.id)

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

    Device.all.all? { |device| device.blacklisted? }.should be_false
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
    user = build_user({
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
    Role.should_receive(:get).with(user.role_ids.first).and_return(role)
    user.roles.should == [role]
  end

  describe "check params in hash" do
    before { @user = build_user }
    it "role ids should not be assignable" do
      @user.has_role_ids?({:role_ids => ""}).should be_true
    end
    it "disabled should not be assignable" do
      @user.has_disable_field?({:disabled => ""}).should be_true
    end

  end

  describe "user roles" do
    it "should store the roles and retrive them back as Roles" do
      admin_role = Role.create!(:name => "Admin", :permissions => [Permission::ADMIN[:admin]])
      field_worker_role = Role.create!(:name => "Field Worker", :permissions => [Permission::CHILDREN[:register]])
      user = User.create({:user_name => "user_123", :full_name => 'full', :password => 'password', :password_confirmation => 'password',
                          :email => 'em@dd.net', :organisation => 'TW', :user_type => 'user_type', :role_ids => [admin_role.id, field_worker_role.id], :disabled => 'false'})

      User.find_by_user_name(user.user_name).roles.should == [admin_role, field_worker_role]
    end

    it "should require atleast one role" do
      user = build_user(:role_ids => [])
      user.should_not be_valid
      user.errors.on(:role_ids).should == ["Please select at least one role"]
    end

    describe 'permissions' do
      subject { stub_model User, :permissions => [ 1, 2, 3, 4 ] }

      it { should have_permission 1 }
      it { should_not have_permission 5 }

      it { should have_any_permission 1 }
      it { should have_any_permission 1,2,3,4 }
      it { should_not have_any_permission 5 }
    end
  end

  describe "can disable" do
    it "should return true if the user has permission to disable or if the user is admin" do
      Role.all.each { |r| r.destroy }
      admin_role = Role.create!(:name => "Admin", :permissions => [Permission::ADMIN[:admin]])
      disable_user = Role.create!(:name => "Disable User", :permissions => [Permission::USERS[:disable]])
      create_user = Role.create!(:name => "Create User", :permissions => [Permission::USERS[:create_and_edit]])

      user = build_and_save_user(:role_ids => [admin_role.id])
      user.can_disable?.should == true

      user = build_and_save_user(:role_ids => [disable_user.id])
      user.can_disable?.should == true

      user = build_and_save_user(:role_ids => [create_user.id])
      user.can_disable?.should == false

    end
  end

end
