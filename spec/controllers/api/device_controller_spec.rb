require 'spec_helper'

describe Api::DeviceController do
  describe '#is_blacklisted' do
    it 'does not authenticate' do
      controller.should_not_receive(:check_authentication)
      get :is_blacklisted, :imei => '123123'
    end

    it 'is true if device IMEI is blacklisted' do
      device = Device.create({:imei => 123123, :blacklisted => "true",:user_name => "bob"})
      Device.stub(:find_by_imei_view).and_return([device])

      get :is_blacklisted, :imei => '123123'
      response.body.should == "{\"blacklisted\":true}"
    end

    it 'is false if device IMEI is not blacklisted' do
      device = Device.create({:imei => 123123, :blacklisted => "false",:user_name => "bob"})
      Device.stub(:find_by_imei_view).and_return([device])

      get :is_blacklisted, :imei => '123123'
      response.body.should == "{\"blacklisted\":false}"
    end

    it 'is renders an error if device IMEI does not exist' do
      Device.stub(:find_by_imei_view).and_return([])

      get :is_blacklisted, :imei => '123123'
      response.response_code.should == 404
      JSON.parse(response.body)["error"].should == "Not found"
    end
  end

end
