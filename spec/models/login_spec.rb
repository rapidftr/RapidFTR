require 'spec_helper'

describe Login do
  describe "authenticate" do
    it "should save imei on successful login" do
      imei = "1336"
      mobile_number = "555-555"

      user = mock(User).as_null_object
      User.stub(:find_by_user_name).and_return(user)
      user.stub(:authenticate).and_return true
      user.stub(:devices).and_return([])

      user.should_receive(:add_mobile_login_event).with(imei, mobile_number)
      user.should_receive(:save)

      params = {:imei => imei, :mobile_number => mobile_number}
      login = Login.new(params)
      login.authenticate_user
    end

    it "should not save mobile login event on failed authentication" do
      imei = "1334"
      mobile_number = "555-555"

      user = mock(User).as_null_object
      User.stub(:find_by_user_name).and_return(user)
      user.stub(:authenticate).and_return false
      user.stub(:devices).and_return([])
      
      user.should_not_receive(:add_mobile_login_event).with(imei, mobile_number)

      params = {:imei => imei, :mobile_number => mobile_number}
      login = Login.new(params)
      login.authenticate_user
    end

    it "should not save mobile login events for non-mobile logins" do
      user = mock(User).as_null_object
      User.stub(:find_by_user_name).and_return(user)
      user.stub(:authenticate).and_return true
      user.stub(:devices).and_return([])
      
      user.should_not_receive(:add_mobile_login_event)

      params = {}
      login = Login.new(params)
      login.authenticate_user
    end
    
    it "should not allow blacklisted imei to login" do
      imei = "1335"
      mobile_number = "555-555"
      
      user = mock(User).as_null_object
      User.stub(:find_by_user_name).and_return(user)
      user.stub(:authenticate).and_return true
      user.stub(:devices).and_return([Device.new({:imei => "1335", :blacklisted => true})])
      
      User.stub(:find_by_user_name).and_return(user)
      user.stub(:authenticate).and_return true

      params = {:imei => imei, :mobile_number => mobile_number}
      login = Login.new(params)
      login.authenticate_user.should == nil
    end
  end
end