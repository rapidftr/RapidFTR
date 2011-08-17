require 'spec_helper'

describe PasswordRecoveryRequest do
  context 'a new request' do
    before do
      @request = PasswordRecoveryRequest.new :user_name => "duck" 
      @request.save
    end
    it "should tell new requests that were not hidden" do
      PasswordRecoveryRequest.to_display.should =~ [ @request ]
    end
    context 'hiding a request' do
      before { @request.hide! } 
      it 'should not be displayed' do
        PasswordRecoveryRequest.to_display.should =~ []
      end 
    end
  end
end
