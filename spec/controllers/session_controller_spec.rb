require 'spec_helper'

describe SessionsController do

  it "should respond with text ok" do
    get :active
    response.body.should == 'OK'
  end

end