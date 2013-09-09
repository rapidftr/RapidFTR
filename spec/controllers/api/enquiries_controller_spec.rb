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

    it "should fail to update when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:update, Enquiry).and_return(false)
      test_id = "12345"
      put :update, :id => test_id, :enquiry => {:id => test_id, :reporter_name => 'new name'}, :format => :json
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
      response.response_code.should == 201
    end

    it "should not update record if it exists and return error" do
      enquiry = Enquiry.new({:reporter_name => 'old name'})
      enquiry.save!
      controller.stub(:authorize!)

      post :create, :enquiry => {:id => enquiry.id, :reporter_name => 'new name'}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'old name'
      response.should be_forbidden
      JSON.parse(response.body)["error"].should == "Forbidden"
    end
  end

  describe "PUT update" do

    it "should sanitize the parameters if the params are sent as string(params would be as a string hash when sent from mobile)" do
      enquiry = Enquiry.create({:reporter_name => "Machaba"})
      controller.stub(:authorize!)

      put :update, :id => enquiry.id, :format => :json, :enquiry => {:id => enquiry.id,:reporter_name => "Manchaba"}.to_json

      response.response_code.should == 200

    end

    it "should return an error if enquiry does not exist" do
      controller.stub(:authorize!)
      id = "12345"
      Enquiry.stub!(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :reporter_name => 'new name'}, :format => :json

      response.response_code.should == 404
      JSON.parse(response.body)["error"].should == "Not found"
    end

    it "should update record if it exists and return the updated record" do
      controller.stub(:authorize!)
      enquiry = Enquiry.create({:reporter_name => 'old name'})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :reporter_name => 'new name'}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'new name'
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end


  end
end
