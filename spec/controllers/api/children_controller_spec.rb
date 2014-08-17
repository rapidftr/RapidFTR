require 'spec_helper'

describe Api::ChildrenController, :type => :controller do

  before :each do
    fake_admin_login
  end

  describe '#authorizations' do
    it "should fail GET index when unauthorized" do
      expect(@controller.current_ability).to receive(:can?).with(:index, Child).and_return(false)
      get :index
      expect(response).to be_forbidden
    end

    it "should fail GET show when unauthorized" do
      expect(@controller.current_ability).to receive(:can?).with(:show, Child).and_return(false)
      get :show, :id => "123"
      expect(response).to be_forbidden
    end

    it "should fail to POST create when unauthorized" do
      expect(@controller.current_ability).to receive(:can?).with(:create, Child).and_return(false)
      post :create
      expect(response).to be_forbidden
    end
  end

  describe "GET index" do
    it "should render all children as json" do
      expect(Child).to receive(:all).and_return(double(:to_json => "all the children"))

      get :index, :format => "json"

      expect(response.body).to eq("all the children")
    end
  end

  describe "GET show" do
    it "should render a child record as json" do
      expect(Child).to receive(:get).with("123").and_return(double(:compact => double(:to_json => "a child record")))
      get :show, :id => "123", :format => "json"
      expect(response.body).to eq("a child record")
    end

    it "should return a 404 with empty body if no child record is found" do
      expect(Child).to receive(:get).with("123").and_return(nil)
      get :show, :id => "123", :format => "json"
      expect(response.response_code).to eq(404)
      expect(response.body).to eq("")
    end

    it "should return a 403 if the device is blacklisted" do
      expect(controller).to receive(:check_device_blacklisted) { raise ErrorResponse.forbidden("Device Blacklisted") }
      get :show, :id => "123", :format => "json"
      expect(response.response_code).to eq(403)
    end

  end

  describe "POST create" do
    it "should update the child record instead of creating if record already exists" do
      allow(User).to receive(:find_by_user_name).with("uname").and_return(user = double('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, :name => 'old name')
      child.save!
      allow(controller).to receive(:authorize!)

      post :create, :child => {:unique_identifier => child.unique_identifier, :name => 'new name'}

      updated_child = Child.by_short_id(:key => child.short_id)
      expect(updated_child.rows.size).to eq(1)
      expect(updated_child.first.name).to eq('new name')
    end
  end

  describe "PUT update" do
    it "should allow a records ID to be specified to create a new record with a known id" do
      new_uuid = UUIDTools::UUID.random_create
      put :update, :id => new_uuid.to_s, :child => {:id => new_uuid.to_s, :_id => new_uuid.to_s, :last_known_location => "London", :age => "7"}

      expect(Child.get(new_uuid.to_s)[:unique_identifier]).not_to be_nil
    end
  end

  describe "#unverified" do
    before :each do
      @user = build :user, :verified => false, :role_ids => []
      fake_login @user
    end

    it "should mark all children created as verified/unverifid based on the user" do
      @user.verified = true
      expect(Child).to receive(:new_with_user_name).with(@user, "name" => "timmy", "verified" => @user.verified?).and_return(child = Child.new)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => "timmy"}

      @user.verified = true
    end

    it "should set the created_by name to that of the user matching the params" do
      expect(Child).to receive(:new_with_user_name).and_return(child = Child.new)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => "timmy"}

      expect(child['created_by_full_name']).to eq @user.full_name
    end

    it "should update the child instead of creating new child everytime" do
      child = Child.new
      view = double(CouchRest::Model::Designs::View)
      expect(Child).to receive(:by_short_id).with(:key => '1234567').and_return(view)
      expect(view).to receive(:first).and_return(child)
      expect(controller).to receive(:update_child_from).and_return(child)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => "timmy", :unique_identifier => '12345671234567'}

      expect(child['created_by_full_name']).to eq @user.full_name
    end
  end

end
