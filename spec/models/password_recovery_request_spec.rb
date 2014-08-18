require 'spec_helper'

describe PasswordRecoveryRequest, :type => :model do
  context 'a new request' do
    it 'should display requests that were not hidden' do
      PasswordRecoveryRequest.create!(:user_name => 'evilduck')
      PasswordRecoveryRequest.create!(:user_name => 'goodduck', :hidden => true)
      expect(PasswordRecoveryRequest.to_display.map(&:user_name)).to include('evilduck')
      expect(PasswordRecoveryRequest.to_display.map(&:user_name)).not_to include('goodduck')
    end

    it 'should raise error if username is empty' do
      expect { PasswordRecoveryRequest.create!(:user_name => '') }.to raise_error
    end

    it 'should hide password requests' do
      request = PasswordRecoveryRequest.create!(:user_name => 'moderateduck')
      request.hide!
      expect(PasswordRecoveryRequest.to_display.map(&:user_name)).not_to include('moderateduck')
    end
  end
end
