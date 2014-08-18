require 'spec_helper'

describe PasswordRecoveryRequestsController, :type => :controller do

  before :each do
    allow(controller).to receive(:current_session).and_return(nil)
  end

  it 'should create password recovery request' do
    valid_params = {'user_name' => 'ygor'}
    expect(PasswordRecoveryRequest).to receive(:new).with(valid_params).and_return(recovery_request = double)
    expect(recovery_request).to receive(:save).and_return true

    post :create, :password_recovery_request => valid_params

    expect(flash[:notice]).to eq('Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly.')
    expect(response).to redirect_to(login_path)
  end

  it 'should report error when password recovery request is invalid' do
    invalid_params = {'user_name' => ''}
    expect(PasswordRecoveryRequest).to receive(:new).with(invalid_params).and_return(recovery_request = double)
    expect(recovery_request).to receive(:save).and_return false

    post :create, :password_recovery_request => invalid_params

    expect(response).to render_template(:new)
    expect(assigns[:password_recovery_request]).to eq(recovery_request)
  end
end
