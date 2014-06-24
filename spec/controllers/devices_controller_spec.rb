require 'spec_helper'

describe DevicesController do


  describe "GET index" do
    it "fetches all the blacklisted devices but not the replication details if user have only black listed permission" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double({:user_name => "someone"})
      Device.should_receive(:view).with("by_imei").and_return([device])
      Replication.should_not_receive(:all)
      get :index
      assigns[:devices].should == [device]
    end

    it "should not show black listed devices, if the user have only manage replication permission" do
      fake_login_as(Permission::DEVICES[:replications])
      Device.should_not_receive(:view).with("by_imei")
      Replication.should_receive(:all)
      get :index
    end

    it "should show black listed devices and the replications if the user have both the permissions" do
      fake_login_as([Permission::DEVICES[:replications], Permission::DEVICES[:black_list]].flatten)
      Replication.should_receive(:all)
      Device.should_receive(:view)
      get :index
    end
  end
  describe "POST update_blacklist" do
    it "should update the blacklist flag" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double()
      Device.should_receive(:find_by_device_imei).with("123").and_call_original
      Device.should_receive(:by_imei).with(:key => "123").and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => true}).and_return(true)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "{\"status\":\"ok\"}"
    end

    it "should return failure if blacklist fails" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double()
      Device.should_receive(:find_by_device_imei).with("123").and_call_original
      Device.should_receive(:by_imei).with(:key => "123").and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => true}).and_return(false)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "{\"status\":\"error\"}"
    end

    it "should not update the device by user without blacklist permission" do
      fake_login_as(Permission::USERS[:create_and_edit])
      Device.should_not_receive(:view).with("by_imei")
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.status.should == 403
    end
  end

end
