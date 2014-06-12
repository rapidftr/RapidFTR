require 'spec_helper'

class TestController < Api::ApiController
  def index
    render :json => "blah"
  end
end

describe TestController do
  before :each do
    Rails.application.routes.draw do
      # add the route that you need in order to test
      match '/' => "test#index"
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
    response.body.should == "Invalid request"
  end

  it "should extend session lifetime" do
    last_access_time = DateTime.now
    Clock.stub(:now).and_return(last_access_time)
    controller.stub(:logged_in?).and_return(true)

    get :index
    controller.session[:last_access_time].should == last_access_time.rfc2822
  end
end
