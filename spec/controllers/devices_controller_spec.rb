require 'spec_helper'

describe DevicesController do


  describe "GET index" do
    it "fetches all the devices" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = mock({:user_name => "someone"})
      Device.should_receive(:view).with("by_imei").and_return([device])
      get :index
      assigns[:devices].should == [device]
    end

    it "should not view the devices for user without blacklist permission" do
      fake_login_as(Permission::USERS[:create_and_edit])
      Device.should_not_receive(:view).with("by_imei")
      get :index
      response.should render_template("#{Rails.root}/public/403.html")
    end

  end
  describe "POST update_blacklist" do
    it "should update the blacklist flag" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = mock()
      Device.should_receive(:by_imei).with(:key => 123).and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => "true"}).and_return(true)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "{\"status\":\"ok\"}"
    end

    it "should return failure if blacklist fails" do
      fake_login_as(Permission::DEVICES[:black_list])
      device = mock()
      Device.should_receive(:by_imei).with(:key => 123).and_return([device])
      device.should_receive(:update_attributes).with({:blacklisted => "true"}).and_return(false)
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.body.should == "{\"status\":\"error\"}"
    end

    it "should not update the device by user without blacklist permission" do
      fake_login_as(Permission::USERS[:create_and_edit])
      Device.should_not_receive(:view).with("by_imei")
      post :update_blacklist, {:imei => "123", :blacklisted => "true"}
      response.should render_template("#{Rails.root}/public/403.html")
    end
  end

end
