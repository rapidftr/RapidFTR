require 'spec_helper'

class TestController < Api::ApiController
  def index
    render :json => 'blah'
  end

  def forbidden
    authorize! :index, NilClass
  end
end

describe TestController, :type => :controller do
  before :each do
    Rails.application.routes.draw do
      # add the route that you need in order to test
      get '/' => 'test#index'
      get '/forbidden' => 'test#forbidden'
    end
  end

  after :each do
    # be sure to reload routes after the tests run, otherwise all your
    # other controller specs will fail
    Rails.application.reload_routes!
  end

  it 'should return 422 for malformed json' do
    allow(controller).to receive(:logged_in?).and_return(true)
    allow(controller).to receive(:index) { fail ActiveSupport::JSON.parse_error }
    get :index
    expect(response.response_code).to eq(422)
    expect(response.body).to eq(I18n.t('session.invalid_request'))
  end

  it 'should throw HTTP 401 when session is expired' do
    allow(controller).to receive(:logged_in?).and_return(false)
    get :index
    expect(response.response_code).to eq(401)
    expect(response.body).to eq(I18n.t('session.has_expired'))
  end

  it 'should throw HTTP 403 when not authorized' do
    allow(controller).to receive(:logged_in?).and_return(true)
    allow(controller).to receive(:current_ability).and_return(Ability.new(build :user))
    get :forbidden
    expect(response.response_code).to eq(403)
    expect(response.body).to eq(I18n.t('session.forbidden'))
  end

  it 'should throw HTTP 403 when device is blacklisted' do
    session = build :session
    expect(session).to receive(:device_blacklisted?).and_return(true)
    allow(controller).to receive(:current_session).and_return(session)
    allow(controller).to receive(:logged_in?).and_return(true)
    get :index
    expect(response.response_code).to eq(403)
    expect(response.body).to eq(I18n.t('session.device_blacklisted'))
  end

  it 'should override session expiry timeout from configuration' do
    allow(Rails.application.config.session_options[:rapidftr]).to receive(:[]).with(:mobile_expire_after).and_return(100.minutes)
    expect(controller.send(:session_expiry_timeout)).to eq(100.minutes)
  end

  it 'should extend session lifetime' do
    last_access_time = DateTime.now
    allow(Clock).to receive(:now).and_return(last_access_time)
    allow(controller).to receive(:logged_in?).and_return(true)

    get :index
    expect(controller.session[:last_access_time]).to eq(last_access_time.rfc2822)
  end
end
