require 'spec_helper'

describe Api::EnquiriesController do

  before :each do
    fake_admin_login
  end

  describe '#authorizations' do
    it "should fail to POST create when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:create, Enquiry).and_return(false)
      post :create, :format => :json
      response.should be_forbidden
    end
  end


  describe "POST create" do
    it "should create the enquiry record" do
      controller.stub(:authorize!)
      reporter_name = 'reporter'

      post :create, :enquiry => {:reporter_name => reporter_name}, :format => :json

      Enquiry.all.size.should == 1
      enquiry = Enquiry.all.first
      enquiry.reporter_name.should == reporter_name
    end
  end

end
