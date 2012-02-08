require 'spec_helper'

describe Session do
  describe "expiration" do
    before(:each) do
      @session = Session.new()
      @fifteen_minutes_from_now = 15.minutes.from_now
      @twenty_minutes_from_now = @fifteen_minutes_from_now + 5.minutes
      @twenty_five_minutes_from_now = @twenty_minutes_from_now + 5.minutes
    end

    describe "expired?" do
      it "is not expired right after creation" do
        @session.expired?.should be_false
      end

      it "is not expired if time is within the expiration range" do
        @session.update_expiration_time(@twenty_minutes_from_now)
        Clock.stub!(:now).and_return(@fifteen_minutes_from_now)
        @session.expired?.should be_false
      end

      it "expires after a given time" do
        @session.update_expiration_time(@twenty_minutes_from_now)
        Clock.stub!(:now).and_return(@twenty_five_minutes_from_now)
        @session.expired?.should be_true
      end
    end

    describe "will_expire_soon?" do
      it "is not expiring soon right after creation" do
        @session.will_expire_soon?.should be_false
      end

      it "is expiring soon after 15 minutes" do
        @session.update_expiration_time(@twenty_minutes_from_now)
        Clock.stub!(:now).and_return(@fifteen_minutes_from_now)
        @session.will_expire_soon?.should be_true
      end
    end
  end
  
  describe "device blacklisting" do
    it "should not allow blacklisted imei to login" do
      imei = "1335"
      user = mock(User).as_null_object
      Device.stub(:all).and_return([Device.new({:imei => "1335", :blacklisted => true})])

      session = Session.for_user(user, imei)
      session.device_blacklisted?.should == true
    end

    it "should allow non blacklisted imei to login" do
      imei = "1335"
      user = mock(User).as_null_object
      Device.stub(:all).and_return([Device.new({:imei => "1335", :blacklisted => false})])

      session = Session.for_user(user, imei)
      session.device_blacklisted?.should == false 
    end
  end

  describe "admin?" do

    before(:each) do
      @user = User.new 
      @session = Session.for_user(@user, "")
    end

    it "should return true when user is an administrator" do
      @user.user_type = "Administrator"
      Session.for_user(@user, "").admin?.should == true
    end

    it "should return false when user is just a basic user" do
      @user.user_type = "BasicUser"
      Session.for_user(@user, "").admin?.should == false
    end
  end
end
