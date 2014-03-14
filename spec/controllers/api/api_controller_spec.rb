require 'spec_helper'

class TestController < Api::ApiController

  def index
    render :json => "blah"
  end

end

describe TestController do

  before do
    Rails.application.routes.draw do

      # add the route that you need in order to test
      get '/', to: "test#index"

    end
  end

  after do

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
end
