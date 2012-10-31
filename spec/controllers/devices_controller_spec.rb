require 'spec_helper'

describe DevicesController do
  before do
    fake_admin_login
  end
  describe "GET index" do
    it "fetches all the devices" do
      device = mock({:user_name => "someone"})
      Device.should_receive(:view).with("by_imei").and_return([device])
      get :index
      assigns[:devices].should == [device]
    end
  end
  describe "POST update_blacklist" do
    it "should update the blacklist flag" do
      device = mock()
      Device.should_receive(:by_imei).with("123").and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => "true"}).and_return(true)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "Success"
    end

    it "should return failure if blacklist fails" do
      device = mock()
      Device.should_receive(:by_imei).with("123").and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => "true"}).and_return(false)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "Failure"
    end
  end

end
