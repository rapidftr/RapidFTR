require "spec_helper"

describe Api::EnquiriesController do

  before :each do
    fake_admin_login
  end

  describe "#authorizations" do
    it "should fail to POST create when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:create, Enquiry).and_return(false)
      post :create 
      response.should be_forbidden
    end

    it "should fail to update when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:update, Enquiry).and_return(false)
      test_id = "12345"
      put :update, :id => test_id, :enquiry => {:id => test_id, :reporter_name => "new name"} 
      response.should be_forbidden
    end
  end


  describe "POST create" do
    it "should create the enquiry record and return a success code" do
      controller.stub(:authorize!)
      name = "reporter"

      details = {"location" => "Kampala"}

      post :create, :enquiry => {:reporter_name => name, :reporter_details => details, :criteria => {:name => "name"}} 

      Enquiry.all.size.should == 1
      enquiry = Enquiry.all.first

      enquiry.reporter_name.should == name
      enquiry.reporter_details.should == details
      response.response_code.should == 201
    end

    it "should not create enquiry without criteria" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name", :reporter_details => {"location" => "kampala"}} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
    end

    it "should not create enquiry with empty criteria" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name", :criteria => {}} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
    end

    it "should not create enquiry without reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name", :criteria => {"location" => "kampala"}} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with empty reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name", :reporter_details => {}, :criteria => {"location" => "kampala"}} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with out both criteria and reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name"} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not create enquiry with empty criteria and empty reporter details" do
      controller.stub(:authorize!)
      post :create, :enquiry => {:reporter_name => "new name", :reporter_details => {}, :criteria => {}} 
      response.response_code.should == 422
      JSON.parse(response.body)["error"].should include("Please add criteria to your enquiry")
      JSON.parse(response.body)["error"].should include("Please add reporter details to your enquiry")
    end

    it "should not update record if it exists and return error" do
      enquiry = Enquiry.new({:reporter_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => {:name => "name"}})
      enquiry.save!
      controller.stub(:authorize!)

      post :create, :enquiry => {:id => enquiry.id, :reporter_name => "new name", :criteria => {:name => "name"}} 

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == "old name"
      response.should be_forbidden
      JSON.parse(response.body)["error"].should == "Forbidden"
    end
  end

  describe "PUT update" do

    it "should return an error if enquiry does not exist" do
      controller.stub(:authorize!)
      id = "12345"
      Enquiry.stub!(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :reporter_name => "new name"} 

      response.response_code.should == 404
      JSON.parse(response.body)["error"].should == "Not found"
    end

    it "should not override existing criteria or reporter_details when sending empty criteria or reporter_details" do
      controller.stub(:authorize!)
      criteria = {"name" => "Batman"}
      details = {"location" => "kampala"}
      enquiry = Enquiry.new({:reporter_name => "old name", :reporter_details => details, :criteria => criteria})
      enquiry.save!

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :reporter_name => "new name", :criteria => {}, :reporter_details => {}} 

      response.response_code.should == 200
      Enquiry.get(enquiry.id)[:criteria].should == criteria
      Enquiry.get(enquiry.id)[:reporter_details].should == details
      JSON.parse(response.body)["error"].should be_nil
    end


    it "should update record if it exists and return the updated record" do
      controller.stub(:authorize!)
      details = {"location" => "kampala"}
      enquiry = Enquiry.create({:reporter_name => "old name", :reporter_details => details, :criteria => {:name => "name"}})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :reporter_name => "new name"} 

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == "new name"
      enquiry.reporter_details.should == details
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

    it "should update record without passing the id in the enquiry params" do
      controller.stub(:authorize!)
      enquiry = Enquiry.create({:reporter_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => {:name => "name"}})

      put :update, :id => enquiry.id, :enquiry => {:reporter_name => "new name"} 

      enquiry = Enquiry.get(enquiry.id)
      enquiry.reporter_name.should == "new name"
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

    it "should merge updated fields and return the latest record" do
      controller.stub(:authorize!)
      enquiry = Enquiry.create({:reporter_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => {:name => "child name"}})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :criteria => {:name => "child new name"}} 

      enquiry = Enquiry.get(enquiry.id)
      enquiry.criteria.should == {"name" => "child new name"}

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :location => "Kampala", :reporter_details => {"age" => "100"}, :criteria => {:sex => "female"}} 

      enquiry = Enquiry.get(enquiry.id)

      enquiry.criteria.should == {"name" => "child new name", "sex" => "female"}
      enquiry.reporter_details.should == {"location" => "kampala", "age" => "100"}
      enquiry["location"].should == "Kampala"
      response.response_code.should == 200
      JSON.parse(response.body).should == enquiry
    end

  end

  describe "GET index" do

    it "should fetch all the enquiries" do
      controller.stub(:authorize!)

      enquiry = Enquiry.new({:_id => "123"})
      Enquiry.should_receive(:all).and_return([enquiry])

      get :index 
      response.response_code.should == 200
      response.body.should == [{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json
    end

    it "should return enquiries with new matches when passed query parameter with last update timestamp" do
      controller.stub(:authorize!)

      enquiry = Enquiry.new({:_id => "123"})
      Enquiry.should_receive(:search_by_match_updated_since).with('2013-09-18 06:42:12UTC').and_return([enquiry])

      get :index, :updated_after => '2013-09-18 06:42:12UTC' 

      response.response_code.should == 200
      response.body.should == [{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json
    end

    it "should return 422 if query parameter with last update timestamp is not a valid timestamp" do
      controller.stub(:authorize!)
      bypass_rescue
      get :index, :updated_after => 'adsflkj' 

      response.response_code.should == 422
    end

  end

  describe "GET show" do
    it "should fetch a particular enquiry" do
      controller.stub(:authorize!)

      Enquiry.should_receive(:get).with("123").and_return(mock(:to_json => "an enquiry record"))

      get :show, :id => "123" 
      response.response_code.should == 200
      response.body.should == "an enquiry record"
    end

    it "should return a 404 with empty body if enquiry record does not exist" do
      controller.stub(:authorize!)

      Enquiry.should_receive(:get).with("123").and_return(nil)

      get :show, :id => "123" 

      response.body.should == ""
      response.response_code.should == 404
    end

  end

end
