require 'spec_helper'

describe Api::ChildrenController do

  before :each do
    fake_admin_login    
	end

  describe '#authorizations' do
    it "should fail GET index when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:index, Child).and_return(false)

      get :index, :format => "json"

      response.status.should == 403
      response.body.should == "unauthorized"
    end

    it "should fail GET show when unauthorized" do 
  		@controller.current_ability.should_receive(:can?).with(:show, Child).and_return(false)

      get :show, :id => "123", :format => "json"

      response.status.should == 403
      response.body.should == "unauthorized"
  	end

    it "should fail to POST create when unauthorized" do
      @controller.current_ability.should_receive(:can?).with(:create, Child).and_return(false)
      
      post :create, :format => :json
      
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

  describe "GET show" do 
  	it "should render a child record as json" do 
  		Child.should_receive(:get).with("123").and_return(mock(:compact => mock(:to_json => "a child record")))

  		get :show, :id => "123", :format => "json"

  		response.body.should == "a child record"
  	end 
  end

  describe "POST create" do
    it "should update the child record instead of creating if record already exists" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'old name'})
      child.save!
      controller.stub(:authorize!)
      
      post :create, :child => {:unique_identifier => child.unique_identifier, :name => 'new name'}, :format => :json
      
      updated_child = Child.by_short_id(:key => child.short_id)
      updated_child.size.should == 1
      updated_child.first.name.should == 'new name'
    end
	end

	describe "PUT update" do 
		it "should sanitize the parameters if the params are sent as string(params would be as a string hash when sent from mobile)" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo, :created_by => "uname")
      child['histories'] = []
      child.save!
      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
      histories = JSON.parse "[{\"datetime\":\"2013-02-01 04:49:29UTC\",\"user_name\":\"rapidftr\",\"changes\":{\"photo_keys\":{\"added\":[\"photo-671592136-2013-02-01T101929\"],\"deleted\":null}},\"user_organisation\":\"N\\/A\"}]"
      
     put :update, :id => child.id, :format => "json", :child => {:last_known_location => "Manchester", :histories => histories}.to_json
     	
     JSON.parse(response.body)['histories'].should == histories
    end

    it "should allow a records ID to be specified to create a new record with a known id" do
      new_uuid = UUIDTools::UUID.random_create()
      put :update, :id => new_uuid.to_s, :child => { :id => new_uuid.to_s, :_id => new_uuid.to_s, :last_known_location => "London", :age => "7" }, :format => :json
      
      Child.get(new_uuid.to_s)[:unique_identifier].should_not be_nil
    end
	end

end	