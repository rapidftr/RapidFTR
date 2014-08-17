require 'spec_helper'

describe Api::DeviceController, :type => :controller do
  describe '#is_blacklisted' do
    it 'does not authenticate' do
      expect(controller).not_to receive(:check_authentication)
      get :is_blacklisted, :imei => '123123'
    end

    it 'is true if device IMEI is blacklisted' do
      device = Device.create(:imei => 123_123, :blacklisted => "true", :user_name => "bob")
      allow(Device).to receive(:find_by_device_imei).and_return([device])

      get :is_blacklisted, :imei => '123123'
      expect(response.body).to eq("{\"blacklisted\":true}")
    end

    it 'is false if device IMEI is not blacklisted' do
      device = Device.create(:imei => 123_123, :blacklisted => "false", :user_name => "bob")
      allow(Device).to receive(:find_by_device_imei).and_return([device])

      get :is_blacklisted, :imei => '123123'
      expect(response.body).to eq("{\"blacklisted\":false}")
    end

    it 'is renders an error if device IMEI does not exist' do
      allow(Device).to receive(:find_by_device_imei).and_return([])

      get :is_blacklisted, :imei => '123123'
      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Not found")
    end
  end

end
