require 'spec_helper'

describe Device, :type => :model do
  describe 'set_appropriate_data_type' do

    it 'should save blacklisted as boolean and imei as string' do
      device1 = Device.create(:imei => 123_123, :blacklisted => 'true', :user_name => 'bob')
      expect(device1).to be_blacklisted
      expect(device1.imei).to eq('123123')
      device2 = Device.create(:imei => '123123', :blacklisted => false, :user_name => 'bob')
      expect(device2).not_to be_blacklisted
      expect(device2.imei).to eq('123123')
    end

  end
end
