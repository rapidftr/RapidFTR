require 'spec_helper'

describe Session do
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

  describe "user" do
    it "should load the user only once" do
      user = User.new(:user_name => "some_name")
      User.should_receive(:find_by_user_name).with(user.user_name).and_return(user)
      session = Session.for_user(user, "")
      session.user.should == user
      User.should_not_receive(:find_by_user_name)
      session.user.should == user
    end
  end
end
