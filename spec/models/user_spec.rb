require 'spec_helper'

describe User, :type => :model do

  describe "validations" do
    it "should not be valid when username contains whitespace" do
      user = build :user, :user_name => "in val id"
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to eq(["Please enter a valid user name"])
    end

    it "should be valid when password contains whitespace" do
      user = build :user, :password => "valid with spaces"
      expect(user).to be_valid
    end

    it "should not be valid when username already exists" do
      create :user, :user_name => "existing_user"
      user = build :user, :user_name => "existing_user"
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to eq(["User name has already been taken! Please select a new User name"])
    end

    it "should not be valid when email address is invalid" do
      user = build :user, :email => "invalid_email"
      expect(user).not_to be_valid
      expect(user.errors[:email]).to eq(["Please enter a valid email address"])
    end

    it "should throw error if organisation detail not entered" do
      user = build :user, :organisation => nil
      expect(user).not_to be_valid
      expect(user.errors[:organisation]).to eq(["Please enter the user's organisation name"])
    end

    it "should default disabled to false" do
      user = User.new :disabled => nil
      expect(user.disabled).to be_falsey
    end

    it "should generate id" do
      user = create :user, :user_name => 'test_user_123', :_id => nil
      expect(user.id).to eq("user-test-user-123")
    end
  end

  it 'should validate uniqueness of username for new users' do
    User.all.each { |user| user.destroy }
    user = build :user, :user_name => 'the_user_name'
    expect(user).to be_valid
    user.create!

    dupe_user = build :user, :user_name => 'the_user_name'
    expect(dupe_user).not_to be_valid
  end

  it 'should consider a re-loaded user as valid' do
    user = build :user
    raise user.errors.full_messages.inspect unless user.valid?
    user.create!

    reloaded_user = User.get(user.id)
    raise reloaded_user.errors.full_messages.inspect unless reloaded_user.valid?
    expect(reloaded_user).to be_valid
  end

  it "should reject saving a changed password if the confirmation doesn't match" do
    user = build :user, password: 'foo', password_confirmation: 'not foo'
    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to include(I18n.t("errors.models.user.password_mismatch"))
  end

  it "should allow password update if confirmation matches" do
    user = create :user
    user.password = 'new_password'
    user.password_confirmation = 'new_password'
    expect(user).to be_valid
  end

  it "doesn't use id for equality" do
    user = create :user
    reloaded_user = User.get(user.id)
    #Now couchrest_model use the id for equality.
    expect(reloaded_user).to eq(user)
    expect(reloaded_user).to eql(user)
    expect(reloaded_user).not_to equal(user)
  end

  it "can't authenticate which isn't saved" do
    user = build :user, :password => "thepass"
    expect { user.authenticate("thepass") }.to raise_error
  end

  it "can authenticate with the right password" do
    user = create :user, :password => "thepass"
    expect(user.authenticate("thepass")).to be_truthy
  end

  it "can't authenticate with the wrong password" do
    user = create :user, :password => "onepassword"
    expect(user.authenticate("otherpassword")).to be_falsey
  end

  it "can't authenticate if disabled" do
    user = create :user, :disabled => "true", :password => "thepass"
    expect(user.authenticate("thepass")).to be_falsey
  end

  it "can't look up password in database" do
    user = create :user, :password => "thepass"
    expect(User.get(user.id).password).to be_nil
  end

  it "can authenticate if not disabled" do
    user = create :user, :disabled => "false", :password => "thepass"
    expect(user.authenticate("thepass")).to be_truthy
  end

  it "should be able to store a mobile login event" do
    imei = "1337"
    mobile_number = "555-555"
    now = Time.parse("2008-06-21 13:30:00 UTC")

    user = create :user
    allow(Clock).to receive(:now).and_return(now)

    user.add_mobile_login_event(imei, mobile_number)
    user.save

    user = User.get(user.id)
    event = user.mobile_login_history.first

    expect(event[:imei]).to eq(imei)
    expect(event[:mobile_number]).to eq(mobile_number)
    expect(event[:timestamp]).to eq(now)
  end

  it "should store list of devices when new device is used" do
    Device.all.each(&:destroy)
    user = create :user
    user.add_mobile_login_event("a imei", "a mobile")
    user.add_mobile_login_event("b imei", "a mobile")
    user.add_mobile_login_event("a imei", "a mobile")
    expect(Device.all.map(&:imei).sort()).to eq(["a imei", "b imei"])
  end

  it "should create devices as not blacklisted" do
    Device.all.each(&:destroy)

    user = create :user
    user.add_mobile_login_event("an imei", "a mobile")

    expect(Device.all.all? { |device| device.blacklisted? }).to be_falsey
  end

  it "should save blacklisted devices to the device list" do
    device = Device.new(:imei => "1234", :blacklisted => false, :user_name => "timothy")
    device.save!

    user = create :user, :user_name => "timothy"
    user.devices = [{"imei" => "1234", "blacklisted" => "true", :user_name => "timothy"}]
    user.save!

    blacklisted_device = user.devices.detect { |device| device.imei == "1234" }
    expect(blacklisted_device.blacklisted).to eq(true)

  end

  it "should have error on password_confirmation if no password_confirmation" do
    user = build :user, :password => "timothy", :password_confirmation => ""
    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).not_to be_nil
  end

  it "should localize date using user's timezone" do
    user = build :user, :time_zone => "American Samoa"
    expect(user.localize_date("2011-11-12 21:22:23 UTC")).to eq("12 November 2011 at 10:22 (SST)")
  end

  it "should localize date using specified format" do
    user = build :user, :time_zone => "UTC"
    expect(user.localize_date("2011-11-12 21:22:23 UTC", "%Y-%m-%d %H:%M:%S (%Z)")).to eq("2011-11-12 21:22:23 (UTC)")
  end

  it "should load roles only once" do
    role = double("roles")
    user = create :user
    expect(Role).to receive(:get).with(user.role_ids.first).and_return(role)
    expect(user.roles).to eq([role])
  end

  describe "user roles" do
    it "should store the roles and retrive them back as Roles" do
      admin_role = Role.create!(:name => "Admin", :permissions => Permission.all_permissions)
      field_worker_role = Role.create!(:name => "Field Worker", :permissions => [Permission::CHILDREN[:register]])
      user = create :user, :role_ids => [admin_role.id, field_worker_role.id]

      expect(User.find_by_user_name(user.user_name).roles).to eq([admin_role, field_worker_role])
    end

    it "should require atleast one role for a verified user" do
      user = build :user, :role_ids => []
      expect(user).not_to be_valid
      expect(user.errors[:role_ids]).to eq(["Please select at least one role"])
    end

    it "allow an unverified user to have no role" do
      expect(build(:user, :role_ids => [], :verified => false)).to be_valid
    end

    describe 'permissions' do
      subject { stub_model User, :permissions => [1, 2, 3, 4] }

      it { is_expected.to have_permission 1 }
      it { is_expected.not_to have_permission 5 }

      it { is_expected.to have_any_permission 1 }
      it { is_expected.to have_any_permission 1, 2, 3, 4 }
      it { is_expected.not_to have_any_permission 5 }
    end
  end

  describe "unverified users" do
    it "should get all un-verified users" do
      unverified_user1 = create :user, :verified => false
      unverified_user2 = create :user, :verified => false
      verified_user = create :user, :verified => true
      all_unverifed_users = User.all_unverified
      expect(all_unverifed_users.map(&:id)).to be_include unverified_user2.id
      expect(all_unverifed_users.map(&:id)).to be_include unverified_user1.id
      expect(all_unverifed_users.map(&:id)).not_to be_include verified_user.id
    end
  end

  describe "share_contact_info" do
    it "should get all users who share contact info" do
      user1 = create :user, share_contact_info: true
      user2 = create :user, share_contact_info: true, verified: false
      user3 = create :user, share_contact_info: true, disabled: true
      user4 = create :user, share_contact_info: false
      user5 = create :user, share_contact_info: true, verified: true, disabled: false

      share_contact_info_users = User.by_share_contact_info
      ids = share_contact_info_users.map(&:id)
      expect(ids).to include user1.id, user5.id
      expect(ids).not_to include user2.id, user3.id, user4.id
    end
  end
end
