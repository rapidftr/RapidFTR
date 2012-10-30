require 'spec_helper'

describe DevicesController do
  before do
    fake_admin_login
  end
  describe "GET index" do
    it "fetches all the devices" do
      device = mock({:user_name => "someone"})
      Device.should_receive(:view).with("by_user_name").and_return([device])
      get :index
      assigns[:devices].should == [device]
    end
  end

end
