require 'spec_helper'

describe Session, :type => :model do
  describe 'device blacklisting' do
    it 'should not allow blacklisted imei to login' do
      imei = '1335'
      user = double(User).as_null_object
      allow(Device).to receive(:all).and_return([Device.new(:imei => '1335', :blacklisted => true)])

      session = Session.for_user(user, imei)
      expect(session.device_blacklisted?).to eq(true)
    end

    it 'should allow non blacklisted imei to login' do
      imei = '1335'
      user = double(User).as_null_object
      allow(Device).to receive(:all).and_return([Device.new(:imei => '1335', :blacklisted => false)])

      session = Session.for_user(user, imei)
      expect(session.device_blacklisted?).to eq(false)
    end
  end

  describe 'user' do
    it 'should load the user only once' do
      user = User.new(:user_name => 'some_name')
      expect(User).to receive(:find_by_user_name).with(user.user_name).and_return(user)
      session = Session.for_user(user, '')
      expect(session.user).to eq(user)
      expect(User).not_to receive(:find_by_user_name)
      expect(session.user).to eq(user)
    end
  end
end
