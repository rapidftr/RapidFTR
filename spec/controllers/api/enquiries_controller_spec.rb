require "spec_helper"

describe Api::EnquiriesController, :type => :controller do

  before :each do
    Enquiry.all.each{|enquiry| enquiry.destroy}
    fake_admin_login
    Sunspot.remove_all!
  end

  describe "#authorizations" do
    it "should fail to POST create when unauthorized" do
      expect(@controller.current_ability).to receive(:can?).with(:create, Enquiry).and_return(false)
      post :create
      expect(response).to be_forbidden
    end

    it "should fail to update when unauthorized" do
      expect(@controller.current_ability).to receive(:can?).with(:update, Enquiry).and_return(false)
      test_id = "12345"
      put :update, :id => test_id, :enquiry => {:id => test_id, :enquirer_name => "new name"}
      expect(response).to be_forbidden
    end
  end


  describe "POST create" do

    it "should trigger the match functionality every time a record is created" do
      allow(controller).to receive(:authorize!)
      name = 'reporter'
      details = {"location" => "Kampala"}
      criteria = {"name" => "Magso"}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :criteria => criteria}, :format => :json
    end

    it "should not trigger the match unless record is created" do
      allow(controller).to receive(:authorize!)
      name = 'reporter'
      details = {"location" => "Kampala"}

      expect(Enquiry).not_to receive(:find_matching_children)

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it "should create the enquiry record and return a success code" do
      allow(controller).to receive(:authorize!)
      name = "reporter"

      details = {"location" => "Kampala"}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :criteria => {:name => "name"}}

      expect(Enquiry.all.total_rows).to eq(1)
      enquiry = Enquiry.all.first

      expect(enquiry.enquirer_name).to eq(name)
      expect(response.response_code).to eq(201)
    end

    it "should not create enquiry without criteria" do
      allow(controller).to receive(:authorize!)
      post :create, :enquiry => {:enquirer_name => "new name", :reporter_details => {"location" => "kampala"}}
      expect(response.response_code).to eq(422)
      expect(JSON.parse(response.body)["error"]).to include("Criteria Please add criteria to your enquiry")
    end

    it "should not create enquiry with empty criteria" do
      allow(controller).to receive(:authorize!)
      post :create, :enquiry => {:enquirer_name => "new name", :criteria => {}}
      expect(response.response_code).to eq(422)
      expect(JSON.parse(response.body)["error"]).to include("Criteria Please add criteria to your enquiry")
    end

    it "should not update record if it exists and return error" do
      enquiry = Enquiry.new({:enquirer_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => {:name => "name"}})
      enquiry.save!
      allow(controller).to receive(:authorize!)

      post :create, :enquiry => {'id' => enquiry.id, :enquirer_name => "new name", :criteria => {:name => "name"}}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq("old name")
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)["error"]).to eq("Forbidden")
    end
  end

  describe "PUT update" do


    before :each do
      create :form_section, name: 'test_form', fields: [
        build(:text_field, name: 'name'),
        build(:text_field, name: 'sex')
      ]
    end

    after :each do
      FormSection.all.each { |form| form.destroy }
    end

    it 'should not update record when criteria is empty' do
      enquiry = Enquiry.create({:enquirer_name => 'Someone', :criteria => {'name' => 'child name'}})
      allow(controller).to receive(:authorize!)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :criteria => {}}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should not update record when criteria is nil' do
      enquiry = Enquiry.create({:enquirer_name => 'Someone', :criteria => {'name' => 'child name'}})
      allow(controller).to receive(:authorize!)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :criteria => nil}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should not update record when there is no criteria' do
      enquiry = Enquiry.create({:enquirer_name => 'Someone', :criteria => {'name' => 'child name'}})
      allow(controller).to receive(:authorize!)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id}, :format => :json

      expect(response.response_code).to eq(422)
    end


    it "should trigger the match functionality every time a record is created" do
      criteria = {"name" => "old name"}
      enquiry = Enquiry.create({:enquirer_name => "Machaba", :reporter_details => {"location" => "kampala"}, :criteria => criteria})
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :criteria => criteria}, :format => :json

      expect(response.response_code).to eq(200)
    end

    it "should not trigger the match unless record is created" do
      criteria = {"name" => "old name"}
      enquiry = Enquiry.create({:enquirer_name => "Machaba", :reporter_details => {"location" => "kampala"}, :criteria => criteria})
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => ''}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it "should return an error if enquiry does not exist" do
      allow(controller).to receive(:authorize!)
      id = "12345"
      allow(Enquiry).to receive(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :enquirer_name => "new name"}

      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Not found")
    end

    it "should merge existing criteria when sending new values in criteria" do
      allow(controller).to receive(:authorize!)
      details = {"location" => "kampala"}
      enquiry = Enquiry.new({:enquirer_name => "old name", :reporter_details => details, :criteria => {"name" => "Batman"}})
      enquiry.save!

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => "new name", :criteria => {"gender" => "Male"}, :reporter_details => {}}

      expect(response.response_code).to eq(200)
      expect(Enquiry.get(enquiry.id)[:criteria]).to eq({"name" => "Batman", "gender" => "Male"})
      expect(Enquiry.get(enquiry.id)[:reporter_details]).to eq(details)
      expect(JSON.parse(response.body)["error"]).to be_nil
    end


    it "should update record if it exists and return the updated record" do
      allow(controller).to receive(:authorize!)
      criteria = {:name => "name"}
      enquiry = Enquiry.create({:enquirer_name => "old name", :criteria => criteria})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => "new name", :criteria => criteria}

      enquiry = Enquiry.get(enquiry.id)

      expect(enquiry.enquirer_name).to eq("new name")
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it "should update record without passing the id in the enquiry params" do
      allow(controller).to receive(:authorize!)
      criteria = {:name => "name"}
      enquiry = Enquiry.create({:enquirer_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => criteria})

      put :update, :id => enquiry.id, :enquiry => {:enquirer_name => "new name", :criteria => criteria}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq("new name")
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it "should merge updated fields and return the latest record" do
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.create({:enquirer_name => "old name", :reporter_details => {"location" => "kampala"}, :criteria => {:name => "child name"}})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :criteria => {:name => "child new name"}}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.criteria).to eq({"name" => "child new name"})

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :location => "Kampala", :reporter_details => {"age" => "100"}, :criteria => {:sex => "female"}}

      enquiry = Enquiry.get(enquiry.id)


      expect(enquiry.criteria).to eq({"name" => "child new name", "sex" => "female"})
      expect(enquiry["reporter_details"]).to eq({"location" => "kampala", "age" => "100"})
      expect(enquiry["location"]).to eq("Kampala")
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it "should update existing enquiry with potential matches", solr: true do
      reset_couchdb!
      create :form_section, fields: [
          build(:text_field, name: 'name'),
          build(:text_field, name: 'age'),
          build(:text_field, name: 'location'),
          build(:text_field, name: 'sex'),
      ]
      Child.reindex!

      allow(controller).to receive(:authorize!)
      child1 = Child.create('name' => "Clayton aquiles", 'created_by' => 'fakeadmin', 'created_organisation' => "stc")
      child2 = Child.create('name' => "Steven aquiles", 'sex' => 'male', 'created_by' => 'fakeadmin', 'created_organisation' => "stc")

      enquiry_json = "{\"enquirer_name\": \"Godwin\",\"criteria\": {\"sex\": \"male\",\"age\": \"10\",\"location\": \"Kampala\"  }}"
      enquiry = Enquiry.new(JSON.parse(enquiry_json))
      enquiry.save!

      expect(Enquiry.get(enquiry.id)['potential_matches']).to include(*[child2.id])

      updated_enquiry = "{\"criteria\": {\"name\": \"aquiles\", \"age\": \"10\", \"location\": \"Kampala\"}}"

      put :update, :id => enquiry.id, :enquiry => updated_enquiry

      expect(response.response_code).to eq(200)

      enquiry_after_update = Enquiry.get(enquiry.id)
      expect(enquiry_after_update['potential_matches'].size).to eq(2)
      expect(enquiry_after_update['potential_matches'].include?(child1.id)).to eq(true)
      expect(enquiry_after_update['potential_matches'].include?(child2.id)).to eq(true)
      #enquiry_after_update['potential_matches'].size.should == [child2.id,child1.id]
      expect(enquiry_after_update['criteria']).to eq({"name" => "aquiles", "age" => "10", "location" => "Kampala"})
    end

  end

  describe "GET index" do

    it "should fetch all the enquiries" do
      allow(controller).to receive(:authorize!)

      enquiry = Enquiry.new({:_id => "123"})
      expect(Enquiry).to receive(:all).and_return([enquiry])

      get :index
      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json)
    end

    it "should return enquiries with new matches when passed query parameter with last update timestamp" do
      allow(controller).to receive(:authorize!)

      enquiry = Enquiry.new({:_id => "123"})
      expect(Enquiry).to receive(:search_by_match_updated_since).with('2013-09-18 06:42:12UTC').and_return([enquiry])

      get :index, :updated_after => '2013-09-18 06:42:12UTC'

      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json)
    end

    it "should return 422 if query parameter with last update timestamp is not a valid timestamp" do
      allow(controller).to receive(:authorize!)
      bypass_rescue
      get :index, :updated_after => 'adsflkj'

      expect(response.response_code).to eq(422)
    end

  end

  describe "GET show" do
    it "should fetch a particular enquiry" do
      allow(controller).to receive(:authorize!)

      expect(Enquiry).to receive(:get).with("123").and_return(double(:to_json => "an enquiry record"))

      get :show, :id => "123"
      expect(response.response_code).to eq(200)
      expect(response.body).to eq("an enquiry record")
    end

    it "should return a 404 with empty body if enquiry record does not exist" do
      allow(controller).to receive(:authorize!)

      expect(Enquiry).to receive(:get).with("123").and_return(nil)

      get :show, :id => "123"

      expect(response.body).to eq("")
      expect(response.response_code).to eq(404)
    end

  end

end
