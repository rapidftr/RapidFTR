require 'spec_helper'

describe SessionsController, :type => :controller do

  it 'should respond with text ok' do
    expect(controller).not_to receive(:extend_session_lifetime)
    expect(controller).not_to receive(:check_authentication)
    get :active
    expect(response.body).to eq('OK')
  end

  it 'should return the required fields when the user is authenticated successfully via a mobile device' do
    expect(MobileDbKey).to receive(:find_or_create_by_imei).with('IMEI_NUMBER').and_return(double(:db_key => 'unique_key'))
    mock_user = double(:organisation => 'TW', :verified? => true)
    expect(User).to receive(:find_by_user_name).with(anything).and_return(mock_user)
    allow(Login).to receive(:new).and_return(double(:authenticate_user =>
                              mock_model(Session, :authenticate_user => true, :device_blacklisted? => false, :imei => 'IMEI_NUMBER',
                                   :save => true, :put_in_cookie => true, :user_name => 'dummy', :token => 'some_token', :extractable_options? => false)))

    access_time = DateTime.now
    allow(Clock).to receive(:now).and_return(access_time)

    post :create, :user_name => 'dummy', :password => 'dummy', :imei => 'IMEI_NUMBER', :format => 'json'

    expect(controller.session[:last_access_time]).to eq(access_time.rfc2822)

    json = JSON.parse response.body
    expect(json['db_key']).to eq('unique_key')
    expect(json['organisation']).to eq('TW')
    expect(json['language']).to eq('en')
    expect(json['verified']).to eq(mock_user.verified?)
  end

end
