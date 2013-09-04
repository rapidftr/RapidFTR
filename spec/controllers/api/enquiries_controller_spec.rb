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
    it "should create the enquiry record and return a success code" do
      controller.stub(:authorize!)
      name = 'reporter'

      post :create, :enquiry => {:reporter_name => name}, :format => :json

      Enquiry.all.size.should == 1
      enquiry = Enquiry.all.first

      enquiry.reporter_name.should == name
      response.response_code.should == 200
    end

    it "should not update record if it exists and return error" do
      enquiry = Enquiry.new({:reporter_name => 'old name'})
      enquiry.save!
      controller.stub(:authorize!)

      post :create, :enquiry => {:id => enquiry.id, :reporter_name => 'new name'}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'old name'
      JSON.parse(response.body)["error"].should == "Forbidden"
      response.response_code.should == 403
    end
  end

end
