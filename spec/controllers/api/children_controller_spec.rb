require 'spec_helper'

describe Api::ChildrenController do

  before :each do
    fake_admin_login
	end

  describe '#authorizations' do
    it "should fail GET index when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:index, Child).and_return(false)
      get :index
      response.should be_forbidden
    end

    it "should fail GET show when unauthorized" do
  		@controller.current_ability.should_receive(:can?).with(:show, Child).and_return(false)
      get :show, :id => "123"
      response.should be_forbidden
  	end

    it "should fail to POST create when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:create, Child).and_return(false)
      post :create
      response.should be_forbidden
    end
  end

  describe "GET index" do
  	it "should render all children as json" do
  		Child.should_receive(:all).and_return(mock(:to_json => "all the children"))

			get :index, :format => "json"

			response.body.should == "all the children"
  	end
  end

  describe "GET show" do
  	it "should render a child record as json" do
  		Child.should_receive(:get).with("123").and_return(mock(:compact => mock(:to_json => "a child record")))
  		get :show, :id => "123", :format => "json"
  		response.body.should == "a child record"
    end

    it "should return a 404 with empty body if no child record is found" do
      Child.should_receive(:get).with("123").and_return(nil)
      get :show, :id => "123", :format => "json"
      response.response_code.should == 404
      response.body.should == ""
    end

  end

  describe "POST create" do
    it "should update the child record instead of creating if record already exists" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'old name'})
      child.save!
      controller.stub(:authorize!)

      post :create, :child => {:unique_identifier => child.unique_identifier, :name => 'new name'}

      updated_child = Child.by_short_id(:key => child.short_id)
      updated_child.size.should == 1
      updated_child.first.name.should == 'new name'
    end
	end

	describe "PUT update" do
    it "should allow a records ID to be specified to create a new record with a known id" do
      new_uuid = UUIDTools::UUID.random_create()
      put :update, :id => new_uuid.to_s, :child => { :id => new_uuid.to_s, :_id => new_uuid.to_s, :last_known_location => "London", :age => "7" }

      Child.get(new_uuid.to_s)[:unique_identifier].should_not be_nil
    end
  end

  describe "#unverified" do
    before :each do
      @user = build :user, :verified => false, :role_ids => []
      fake_login @user
    end

    it "should mark all children created as verified/unverifid based on the user" do
      @user.verified = true
      Child.should_receive(:new_with_user_name).with(@user, {"name" => "timmy", "verified" => @user.verified?}).and_return(child = Child.new)
      child.should_receive(:save).and_return true

      post :unverified, {:child => {:name => "timmy"} }

      @user.verified = true
    end

    it "should set the created_by name to that of the user matching the params" do
      Child.should_receive(:new_with_user_name).and_return(child = Child.new)
      child.should_receive(:save).and_return true

      post :unverified, {:child => {:name => "timmy"} }

      child['created_by_full_name'].should eq @user.full_name
    end

    it "should update the child instead of creating new child everytime" do
      Child.should_receive(:by_short_id).with(:key => '1234567').and_return(child = Child.new)
      controller.should_receive(:update_child_from).and_return(child)
      child.should_receive(:save).and_return true

      post :unverified, {:child => {:name => "timmy", :unique_identifier => '12345671234567'} }

      child['created_by_full_name'].should eq @user.full_name
    end
  end

end
