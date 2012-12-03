require 'spec_helper'

describe Device do
  describe "set_appropriate_data_type" do

    it "should save blacklisted as boolean and imei as string" do
      device1 = Device.create({:imei => 123123, :blacklisted => "true",:user_name => "bob"})
      device1.blacklisted.should be_true
      device1.imei.should == "123123"
      device2 = Device.create({:imei => "123123", :blacklisted => false,:user_name => "bob"})
      device2.blacklisted.should be_false
      device2.imei.should == "123123"
    end

  end
end
