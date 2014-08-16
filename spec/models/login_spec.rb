require 'spec_helper'

describe Login, :type => :model do
  describe "authenticate" do
    it "should save imei on successful login" do
      imei = "1336"
      mobile_number = "555-555"

      user = double(User).as_null_object
      allow(User).to receive(:find_by_user_name).and_return(user)
      allow(user).to receive(:authenticate).and_return true
      allow(user).to receive(:devices).and_return([])

      expect(user).to receive(:add_mobile_login_event).with(imei, mobile_number)
      expect(user).to receive(:save)

      params = {:imei => imei, :mobile_number => mobile_number}
      login = Login.new(params)
      login.authenticate_user
    end

    it "should not save mobile login event on failed authentication" do
      imei = "1334"
      mobile_number = "555-555"

      user = double(User).as_null_object
      allow(User).to receive(:find_by_user_name).and_return(user)
      allow(user).to receive(:authenticate).and_return false
      allow(user).to receive(:devices).and_return([])

      expect(user).not_to receive(:add_mobile_login_event).with(imei, mobile_number)

      params = {:imei => imei, :mobile_number => mobile_number}
      login = Login.new(params)
      login.authenticate_user
    end

    it "should not save mobile login events for non-mobile logins" do
      user = double(User).as_null_object
      allow(User).to receive(:find_by_user_name).and_return(user)
      allow(user).to receive(:authenticate).and_return true
      allow(user).to receive(:devices).and_return([])

      expect(user).not_to receive(:add_mobile_login_event)

      params = {}
      login = Login.new(params)
      login.authenticate_user
    end

    it "should not allow unverified users to login" do
      user = double(User).as_null_object
      allow(User).to receive(:find_by_user_name).and_return(user)
      allow(user).to receive(:authenticate).and_return true
      allow(user).to receive(:devices).and_return([])
      allow(user).to receive(:verified).and_return(false)

      expect(user).not_to receive(:add_mobile_login_event)

      params = {}
      login = Login.new(params)
      login.authenticate_user
    end

  end
end