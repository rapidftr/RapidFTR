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

      details = {"location" => "Kampala"}

      post :create, :enquiry => {:reporter_name => name, :reporter_details => details, :criteria => {:name => "name"}}, :format => :json

      Enquiry.all.size.should == 1
      enquiry = Enquiry.all.first

      enquiry.reporter_name.should == name
      enquiry.reporter_details.should == details
      response.response_code.should == 201
    end

    it "should not create enquiry without criteria" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name', :reporter_details => {"location" => "kampala"}}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
    end

    it "should not create enquiry with empty criteria" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name', :criteria => {}}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
    end

    it "should not create enquiry without reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name', :criteria => {"location" => "kampala"}}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with empty reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name', :reporter_details => {},:criteria => {"location" => "kampala"}}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with out both criteria and reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name'}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with empty criteria and empty reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => 'new name', :reporter_details => {},:criteria => {}}, :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry if malformed data is received" do
      controller.stub(:authorize!)
      post :create, :enquiry => 'asdfasdf', :format => :json
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Malformed data was received")
    end

    it "should not update record if it exists and return error" do
      enquiry = Enquiry.new({:reporter_name => 'old name',:reporter_details => {"location" => "kampala"}, :criteria => {:name => "name"}})
      enquiry.save!
      controller.stub(:authorize!)

      post :create, :enquiry => {:id => enquiry.id, :reporter_name => 'new name', :criteria => {:name => "name"}}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'old name'
      response.should be_forbidden
      JSON.parse(response.body)["error"].should == "Forbidden"
    end
  end

  describe "PUT update" do
    it "should sanitize the parameters if the params are sent as string(params would be as a string hash when sent from mobile)" do
      enquiry = Enquiry.create({:reporter_name => "Machaba", :reporter_details => {"location" => "kampala"},:criteria => {:name => "name"}})
      controller.stub(:authorize!)

      put :update, :id => enquiry.id, :format => :json, :enquiry => {:id => enquiry.id,:reporter_name => "Manchaba"}.to_json

      response.response_code.should == 200
    end

    it 'should throw an exception given malformed query' do
      enquiry = Enquiry.create({:reporter_name => "Machaba", :reporter_details => {"location" => "kampala"},:criteria => {:name => "name"}})
      controller.stub(:authorize!)
      malformed_query = "{
                  'enquiry':
                    {
                      'reporter_name': 'dummy enquirer from API',
                      'location' :    'Kampala'
                      'criteria'
                                    {
                                      'name' : 'The updated name of the child'
                                      'sex'  : 'Female'
                                    }
                      }"

      put :update, :id => enquiry.id, :format => :json, :enquiry => malformed_query

      response.response_code.should == 422
      JSON.parse(response.body)["error"].should == "Malformed data was received"
    end

    it "should return an error if enquiry does not exist" do
      controller.stub(:authorize!)
      id = "12345"
      Enquiry.stub!(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :reporter_name => 'new name'}, :format => :json

      response.response_code.should == 404
      JSON.parse(response.body)["error"].should == "Not found"
    end

    it "should not override existing criteria or reporter_details when sending empty criteria or reporter_details" do
      controller.stub(:authorize!)
      criteria = {"name" => "Batman"}
      details = {"location" => "kampala"}
      enquiry = Enquiry.new({:reporter_name => 'old name', :reporter_details => details, :criteria => criteria})
      enquiry.save!

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :reporter_name => 'new name', :criteria => {}, :reporter_details => {}}, :format => :json

      response.response_code.should == 200
      Enquiry.get(enquiry.id)[:criteria].should == criteria
      Enquiry.get(enquiry.id)[:reporter_details].should == details
      JSON.parse(response.body)["error"].should be_nil
    end


    it "should update record if it exists and return the updated record" do
      controller.stub(:authorize!)
      details = {"location" => "kampala"}
      enquiry = Enquiry.create({:reporter_name => 'old name', :reporter_details => details,:criteria => {:name => "name"}})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :reporter_name => 'new name'}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'new name'
      enquiry.reporter_details.should == details
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

    it "should update record without passing the id in the enquiry params" do
      controller.stub(:authorize!)
      enquiry = Enquiry.create({:reporter_name => 'old name', :reporter_details => {"location" => "kampala"}, :criteria => {:name => "name"}})

      put :update, :id => enquiry.id, :enquiry => {:reporter_name => 'new name'}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == 'new name'
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

    it "should merge updated fields and return the latest record" do
      controller.stub(:authorize!)
      enquiry = Enquiry.create({:reporter_name => 'old name', :reporter_details => {"location" => "kampala"},:criteria => {:name => "child name"}})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :criteria => {:name => 'child new name'}}, :format => :json

      enquiry = Enquiry.get(enquiry.id)
      enquiry.criteria.should == {"name" => 'child new name'}

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :location => 'Kampala',  :reporter_details => {"age" => "100"}, :criteria => {:sex => 'female'}}, :format => :json

      enquiry = Enquiry.get(enquiry.id)

      enquiry.criteria.should == {"name" => 'child new name', "sex" => 'female'}
      enquiry.reporter_details.should == {"location" => 'kampala', "age" => '100'}
      enquiry['location'].should == 'Kampala'
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

  end
end
