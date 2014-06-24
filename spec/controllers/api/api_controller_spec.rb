require 'spec_helper'

class TestController < Api::ApiController
  def index
    render :json => "blah"
  end

  def forbidden
    authorize! :index, NilClass
  end
end

describe TestController do
  before :each do
    Rails.application.routes.draw do
      # add the route that you need in order to test
      get '/' => "test#index"
      get'/forbidden' => 'test#forbidden'
    end
  end

  after :each do
    # be sure to reload routes after the tests run, otherwise all your
    # other controller specs will fail
    Rails.application.reload_routes!
  end

  it "should return 422 for malformed json" do
    controller.stub(:logged_in?).and_return(true)
    controller.stub(:index) { raise ActiveSupport::JSON.parse_error }
    get :index
    response.response_code.should == 422
    response.body.should == I18n.t("session.invalid_request")
  end

  it "should throw HTTP 401 when session is expired" do
    controller.stub(:logged_in?).and_return(false)
    get :index
    response.response_code.should == 401
    response.body.should == I18n.t("session.has_expired")
  end

  it "should throw HTTP 403 when not authorized" do
    controller.stub(:logged_in?).and_return(true)
    controller.stub(:current_ability).and_return(Ability.new(build :user))
    get :forbidden
    response.response_code.should == 403
    response.body.should == I18n.t("session.forbidden")
  end

  it "should throw HTTP 403 when device is blacklisted" do
    session = build :session
    session.should_receive(:device_blacklisted?).and_return(true)
    controller.stub(:current_session).and_return(session)
    controller.stub(:logged_in?).and_return(true)
    get :index
    response.response_code.should == 403
    response.body.should == I18n.t("session.device_blacklisted")
  end

  it "should override session expiry timeout from configuration" do
      Rails.application.config.session_options[:rapidftr].stub(:[]).with(:mobile_expire_after).and_return(100.minutes)
      controller.send(:session_expiry_timeout).should == 100.minutes
  end

  it "should extend session lifetime" do
    last_access_time = DateTime.now
    Clock.stub(:now).and_return(last_access_time)
    controller.stub(:logged_in?).and_return(true)

    get :index
    controller.session[:last_access_time].should == last_access_time.rfc2822
  end
end
