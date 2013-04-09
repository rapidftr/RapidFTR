require 'spec_helper'

describe Api::ChildrenController do

  before :each do
    fake_admin_login    
	end

  describe '#authorizations' do
    it "should fail GET index" do
      @controller.current_ability.should_receive(:can?).with(:index, Child).and_return(false);

      get :index, :format => "json"

      response.status.should == 403
      response.body.should == "unauthorized"
    end
  end

  describe "GET index" do
  	it "should render all children as json" do
  		Child.should_receive(:all).and_return(mock(:to_json => "all the children"))

			get :index, :format => "json"  		

			response.body.should == "all the children"
  	end
  end

end