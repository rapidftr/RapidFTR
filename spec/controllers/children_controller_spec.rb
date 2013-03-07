require 'spec_helper'

def inject_export_generator( fake_export_generator, child_data )
	ExportGenerator.stub!(:new).with(child_data).and_return( fake_export_generator )
end

def stub_out_export_generator child_data = []
	inject_export_generator( stub_export_generator = stub(ExportGenerator) , child_data)
	stub_export_generator.stub!(:child_photos).and_return('')
	stub_export_generator
end

def stub_out_child_get(mock_child = mock(Child))
	Child.stub(:get).and_return( mock_child )
	mock_child
end

describe ChildrenController do

  before :each do
    fake_admin_login    
  end

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs).as_null_object
  end

  it 'GET reindex' do
    Child.should_receive(:reindex!).and_return(nil)
    get :reindex
    response.should be_success
  end

  describe '#authorizations' do
    describe 'collection' do
      it "GET index" do
        @controller.current_ability.should_receive(:can?).with(:index, Child).and_return(false);
        get :index
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "GET search" do
        @controller.current_ability.should_receive(:can?).with(:index, Child).and_return(false);
        get :search
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "GET new" do
        @controller.current_ability.should_receive(:can?).with(:create, Child).and_return(false);
        get :new
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "POST create" do
        @controller.current_ability.should_receive(:can?).with(:create, Child).and_return(false);
        post :create
        response.should render_template("#{Rails.root}/public/403.html")
      end

    end

    describe 'member' do
      before :each do
        User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
        @child = Child.create('last_known_location' => "London", :short_id => 'short_id', :created_by => "uname")
        @child_arg = hash_including("_id" => @child.id)
      end

      it "GET show" do
        @controller.current_ability.should_receive(:can?).with(:read, @child_arg).and_return(false);
         get :show, :id => @child.id
         response.should render_template("#{Rails.root}/public/403.html")
      end

      it "PUT update" do
        @controller.current_ability.should_receive(:can?).with(:update, @child_arg).and_return(false);
        put :update, :id => @child.id
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "PUT edit_photo" do
        @controller.current_ability.should_receive(:can?).with(:update, @child_arg).and_return(false);
        put :edit_photo, :id => @child.id
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "PUT update_photo" do
        @controller.current_ability.should_receive(:can?).with(:update, @child_arg).and_return(false);
        put :update_photo, :id => @child.id
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "PUT select_primary_photo" do
        @controller.current_ability.should_receive(:can?).with(:update, @child_arg).and_return(false);
        put :select_primary_photo, :child_id => @child.id, :photo_id => 0
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "GET export_photo_to_pdf" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        get :export_photo_to_pdf, :id => @child.id
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "DELETE destroy" do
        @controller.current_ability.should_receive(:can?).with(:destroy, @child_arg).and_return(false);
        delete :destroy, :id => @child.id
        response.should render_template("#{Rails.root}/public/403.html")
      end
    end
  end

  describe "GET index" do

    shared_examples_for "viewing children by user with access to all data" do
      describe "when the signed in user has access all data" do
        before do
          fake_field_admin_login
          @options ||= {}
          @stubs ||= {}
        end

        it "should assign all childrens as @childrens" do
          page = @options.delete(:page)
          per_page = @options.delete(:per_page)
          children = [mock_child(@stubs)]
          @status ||= "all"
          children.expects(:paginate).returns(children)
          Child.should_receive(:fetch_paginated).with(@options, page, per_page).and_return([1, children])

          get :index, :status => @status
          assigns[:children].should == children
        end
      end
    end

    shared_examples_for "viewing children as a field worker" do
      describe "when the signed in user is a field worker" do
        before do
          @session = fake_field_worker_login
          @stubs ||= {}
          @options ||= {}
          @params ||= {}
        end

        it "should assign the children created by the user as @childrens" do
          children = [mock_child(@stubs)]
          page = @options.delete(:page)
          per_page = @options.delete(:per_page)
          @status ||= "all"
          children.expects(:paginate).returns(children)
          Child.should_receive(:fetch_paginated).with(@options, page, per_page).and_return([1, children])
          @params.merge!(:status => @status)
          get :index, @params
          assigns[:children].should == children
        end
      end
    end

    context "viewing all children" do
      before { @stubs = { :reunited? => false } }
      context "when status is passed for admin" do
        before { @status = "all"}
        before {@options = {:startkey=>["all"], :endkey=>["all", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_name}}
        it_should_behave_like "viewing children by user with access to all data"
      end

      context "when status is passed for field worker" do
        before { @status = "all"}
        before {@options = {:startkey=>["all", "fakefieldworker"], :endkey=>["all","fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_created_at}}

        it_should_behave_like "viewing children as a field worker"
      end

      context "when status is not passed admin" do
        before {@options = {:startkey=>["all"], :endkey=>["all", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_name}}
        it_should_behave_like "viewing children by user with access to all data"
      end

      context "when status is not passed field_worker" do
        before {@options = {:startkey=>["all", "fakefieldworker"], :endkey=>["all","fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_created_at}}
        it_should_behave_like "viewing children as a field worker"
      end

      context "when status is not passed field_worker and order is name" do
        before {@options = {:startkey=>["all", "fakefieldworker"], :endkey=>["all","fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_name}}
        before {@params = {:order_by => 'name'}}
        it_should_behave_like "viewing children as a field worker"
      end

      context "when status is not passed field_worker, order is created_at and page is 2" do
        before {@options = {:view_name=>:by_all_view_with_created_by_created_at, :startkey=>["all", "fakefieldworker", {}], :endkey=>["all", "fakefieldworker"], :descending=>true, :page=>2, :per_page=>20}}
        before {@params = {:order_by => 'created_at', :page => 2}}
        it_should_behave_like "viewing children as a field worker"
      end
    end

    context "viewing reunited children" do
      before do
        @status = "reunited"
        @stubs = {:reunited? => true}
      end
      context "admin" do
        before { @options = {:startkey=>["reunited"], :endkey=>["reunited", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_name} }
        it_should_behave_like "viewing children by user with access to all data"
      end
      context "field worker" do
        before { @options = {:startkey=>["reunited", "fakefieldworker"], :endkey=>["reunited", "fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_created_at}}
        it_should_behave_like "viewing children as a field worker"
      end
    end

    context "viewing flagged children" do
      before { @status = "flagged" }
      context "admin" do
        before {@options = {:startkey=>["flagged"], :endkey=>["flagged", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_name}}
        it_should_behave_like "viewing children by user with access to all data"
      end
      context "field_worker" do
        before {@options = {:startkey=>["flagged", "fakefieldworker"], :endkey=>["flagged", "fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_created_at}}
        it_should_behave_like "viewing children as a field worker"
      end
    end

    context "viewing active children" do
      before do
        @status = "active"
        @stubs = {:reunited? => false}
      end
      context "admin" do
        before {@options = {:startkey=>["active"], :endkey=>["active", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_name}}
        it_should_behave_like "viewing children by user with access to all data"
      end
      context "field worker" do
        before {@options = {:startkey=>["active", "fakefieldworker"], :endkey=>["active", "fakefieldworker", {}], :page=>1, :per_page=>20, :view_name=>:by_all_view_with_created_by_created_at}}
        it_should_behave_like "viewing children as a field worker"
      end
    end
  end

  describe "GET show" do
    it "assigns the requested child" do
      Child.stub!(:get).with("37").and_return(mock_child)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end

    it 'should not fail if primary_photo_id is not present' do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", :created_by => "uname")
      child.create_unique_id
      Child.stub!(:get).with("37").and_return(child)
      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))

      get(:show, :format => 'csv', :id => "37")
    end

    it "should set current photo key as blank instead of nil" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", :created_by => "uname")
      child.create_unique_id
      Child.stub!(:get).with("37").and_return(child)
      assigns[child[:current_photo_key]] == ""
      get(:show, :format => 'json', :id => "37")
    end

    it "orders and assigns the forms" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:enabled_by_order).and_return([:the_form_sections])
      get :show, :id => "37"
      assigns[:form_sections].should == [:the_form_sections]
    end

    it "should flash an error and go to listing page if the resource is not found" do
      Child.stub!(:get).with("invalid record").and_return(nil)
      get :show, :id=> "invalid record"
      flash[:error].should == "Child with the given id is not found"
      response.should redirect_to(:action => :index)
    end

    it "should include duplicate records in the response" do
      Child.stub!(:get).with("37").and_return(mock_child)
      duplicates = [Child.new(:name => "duplicated")]
      Child.should_receive(:duplicates_of).with("37").and_return(duplicates)
      get :show, :id => "37"
      assigns[:duplicates].should == duplicates
    end
  end

  describe "GET new" do
    it "assigns a new child as @child" do
      Child.stub!(:new).and_return(mock_child)
      get :new
      assigns[:child].should equal(mock_child)
    end

    it "orders and assigns the forms" do
      Child.stub!(:new).and_return(mock_child)
      FormSection.should_receive(:enabled_by_order).and_return([:the_form_sections])
      get :new
      assigns[:form_sections].should == [:the_form_sections]
    end
  end

  describe "GET edit" do
    it "assigns the requested child as @child" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:enabled_by_order)
      get :edit, :id => "37"
      assigns[:child].should equal(mock_child)
    end

    it "orders and assigns the forms" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:enabled_by_order).and_return([:the_form_sections])
      get :edit, :id => "37"
      assigns[:form_sections].should == [:the_form_sections]
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested child" do
      Child.should_receive(:get).with("37").and_return(mock_child)
      mock_child.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the children list" do
      Child.stub!(:get).and_return(mock_child(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(children_url)
    end
  end

  describe "PUT update" do
    it "should sanitize the parameters if the params are sent as string(params would be as a string hash when sent from mobile)" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo, :created_by => "uname")
      child['histories'] = []
      child.save!

      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
      histories = "[{\"datetime\":\"2013-02-01 04:49:29UTC\",\"user_name\":\"rapidftr\",\"changes\":{\"photo_keys\":{\"added\":[\"photo-671592136-2013-02-01T101929\"],\"deleted\":null}},\"user_organisation\":\"N\\/A\"}]"
      put :update, :id => child.id,
           :child => {
               :last_known_location => "Manchester",
               :histories => histories
           }
      
     assigns[:child]['histories'].should == JSON.parse(histories)
    end

    it "should update child on a field and photo update" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo, :created_by => "uname")

      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
      put :update, :id => child.id,
        :child => {
          :last_known_location => "Manchester",
          :photo => uploadable_photo_jeff }

      assigns[:child]['last_known_location'].should == "Manchester"
      assigns[:child]['_attachments'].size.should == 2
      updated_photo_key = assigns[:child]['_attachments'].keys.select {|key| key =~ /photo.*?-2010-01-17T140532/}.first
      assigns[:child]['_attachments'][updated_photo_key]['data'].should_not be_blank
    end

    it "should update only non-photo fields when no photo update" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo, :created_by => "uname")

      put :update, :id => child.id,
        :child => {
          :last_known_location => "Manchester",
          :age => '7'}

      assigns[:child]['last_known_location'].should == "Manchester"
      assigns[:child]['age'].should == "7"
      assigns[:child]['_attachments'].size.should == 1
    end

    it "should not update history on photo rotation" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo_jeff, :created_by => "uname")
      Child.get(child.id)["histories"].size.should be 1
      
      expect{put(:update_photo, :id => child.id, :child => {:photo_orientation => "-180"})}.to_not change{Child.get(child.id)["histories"].size}
    end

    it "should allow a records ID to be specified to create a new record with a known id" do
      new_uuid = UUIDTools::UUID.random_create()
      put :update, :id => new_uuid.to_s,
        :child => {
            :id => new_uuid.to_s,
            :_id => new_uuid.to_s,
            :last_known_location => "London",
            :age => "7"
        }
      Child.get(new_uuid.to_s)[:unique_identifier].should_not be_nil
    end

    it "should update flag (cast as boolean) and flag message" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo, :created_by => "uname")
      put :update, :id => child.id,
        :child => {
          :flag => true,
          :flag_message => "Possible Duplicate"
        }
      assigns[:child]['flag'].should be_true
      assigns[:child]['flag_message'].should == "Possible Duplicate"
    end

    it "should update history on flagging of record" do
      current_time_in_utc = Time.parse("20 Jan 2010 17:10:32UTC")
      current_time = Time.parse("20 Jan 2010 17:10:32")
      Clock.stub!(:now).and_return(current_time)
      current_time.stub!(:getutc).and_return current_time_in_utc
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo_jeff, :created_by => "uname")

      put :update, :id => child.id, :child => {:flag => true, :flag_message => "Test"}

      history = Child.get(child.id)["histories"].first
      history['changes'].should have_key('flag')
      history['datetime'].should == "2010-01-20 17:10:32UTC"
    end

    it "should update the last_updated_by_full_name field with the logged in user full name" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'existing child'})
      Child.stub(:get).with(123).and_return(child)
      subject.should_receive('current_user_full_name').any_number_of_times.and_return('Bill Clinton')
      
      put :update, :id => 123, :child => {:flag => true, :flag_message => "Test"}
      
      child['last_updated_by_full_name'].should=='Bill Clinton'
    end

    it "should not set photo if photo is not passed" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'some name'})
      params_child = {"name" => 'update'}
      controller.stub(:current_user_name).and_return("user_name")
      child.should_receive(:update_properties_with_user_name).with("user_name", "", nil, nil, params_child)
      Child.stub(:get).and_return(child)
      put :update, :id => '1', :child => params_child
      end


    it "should redirect to redirect_url if it is present in params" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'some name'})
      params_child = {"name" => 'update'}
      controller.stub(:current_user_name).and_return("user_name")
      child.should_receive(:update_properties_with_user_name).with("user_name", "", nil, nil, params_child)
      Child.stub(:get).and_return(child)
      put :update, :id => '1', :child => params_child, :redirect_url => '/children'
      response.should redirect_to '/children'
    end

    it "should redirect to child page if redirect_url is not present in params" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'some name'})

      params_child = {"name" => 'update'}
      controller.stub(:current_user_name).and_return("user_name")
      child.should_receive(:update_properties_with_user_name).with("user_name", "", nil, nil, params_child)
      Child.stub(:get).and_return(child)
      put :update, :id => '1', :child => params_child
      response.should redirect_to "/children/#{child.id}"
    end

  end

  describe "GET search" do

    it "should not render error by default" do
      get(:search, :format => 'html')
      assigns[:search].should be_nil
    end

    it "should render error if search is invalid" do
      get(:search, :format => 'html', :query => '2'*160)
      search = assigns[:search]
      search.errors.should_not be_empty
    end

    it "should stay in the page if search is invalid" do
      get(:search, :format => 'html', :query => '1'*160)
      response.should render_template("search")
    end

    it "performs a search using the parameters passed to it" do
      search = mock("search", :query => 'the child name', :valid? => true, :page => 1)
      Search.stub!(:new).and_return(search)

      fake_results = ["fake_child","fake_child"]
      fake_full_results =  [:fake_child,:fake_child, :fake_child, :fake_child]
      Child.should_receive(:search).with(search, 1).and_return([fake_results, fake_full_results])
      get(:search, :format => 'html', :query => 'the child name')
      assigns[:results].should == fake_results
    end


    describe "with no results" do
      before do
        Summary.stub!(:basic_search).and_return([])
        get(:search, :query => 'blah')
      end

      it 'asks view to not show csv export link if there are no results' do
        assigns[:results].size.should == 0
      end

      it 'asks view to display a "No results found" message if there are no results' do
        assigns[:results].size.should == 0
      end

    end

    it 'sends csv data with the correct attributes' do
			Child.stub!(:search).and_return([[]])
      controller.stub(:authorize!)
      export_generator = stub(ExportGenerator)
			inject_export_generator(export_generator, [])

			export_generator.should_receive(:to_csv).and_return(ExportGenerator::Export.new(:csv_data, {:foo=>:bar}))
      @controller.stub!(:render) #to avoid looking for a template
      @controller.
        should_receive(:send_csv).
        with( :csv_data, {:foo=>:bar} ).
        and_return{controller.render :nothing => true}

			get(:search, :format => 'csv', :query => 'blah')
    end
  end
  describe "searching as field worker" do
    before :each do
      @session = fake_field_worker_login
    end
    it "should only list the children which the user has registered" do
      search = mock("search", :query => 'some_name', :valid? => true, :page => 1)
      Search.stub!(:new).and_return(search)

      fake_results = [:fake_child,:fake_child]
      fake_full_results =  [:fake_child,:fake_child, :fake_child, :fake_child]
      Child.should_receive(:search_by_created_user).with(search, @session.user_name, 1).and_return([fake_results, fake_full_results])

      get(:search, :query => 'some_name')
      assigns[:results].should == fake_results
    end
  end


  describe "GET export_photo_to_pdf" do

    before do
      user = User.new(:user_name => "some-name")
      user.stub!(:time_zone).and_return TZInfo::Timezone.get("US/Samoa")
      user.stub!(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:export]])])
      fake_login user
      Clock.stub!(:now).and_return(Time.utc(2000, 1, 1, 20, 15))
    end

    it "should return the photo wall pdf for selected child" do
      Child.should_receive(:get).with('1').and_return(stub_child = stub('child', :short_id => '1', :class => Child))

      ExportGenerator.should_receive(:new).and_return(export_generator = mock('export_generator'))
      export_generator.should_receive(:to_photowall_pdf).and_return(:fake_pdf_data)

      @controller.
        should_receive(:send_pdf).
        with(:fake_pdf_data, '1-20000101-0915.pdf').
        and_return{controller.render :nothing => true}

      get :export_photo_to_pdf, :id => '1'
    end
  end

  describe "PUT select_primary_photo" do
    before :each do
      @child = stub_model(Child, :id => :id)
      @photo_key = "key"
      @child.stub(:primary_photo_id=)
      @child.stub(:save)
      Child.stub(:get).with(:id).and_return @child
    end

    it "set the primary photo on the child and save" do
      @child.should_receive(:primary_photo_id=).with(@photo_key)
      @child.should_receive(:save)

      put :select_primary_photo, :child_id => @child.id, :photo_id => @photo_key
    end

    it "should return success" do
      put :select_primary_photo, :child_id => @child.id, :photo_id => @photo_key

      response.should be_success
    end

    context "when setting new primary photo id errors" do
      before :each do
        @child.stub(:primary_photo_id=).and_raise("error")
      end

      it "should return error" do
        put :select_primary_photo, :child_id => @child.id, :photo_id => @photo_key

        response.should be_error
      end
    end
  end

  describe "PUT create" do
    it "should add the full user_name of the user who created the Child record" do
      Child.should_receive('new_with_user_name').and_return(child = Child.new)
      controller.should_receive('current_user_full_name').and_return('Bill Clinton')
      put :create, :child => {:name => 'Test Child' }
      child['created_by_full_name'].should=='Bill Clinton'
    end
  end

  describe "sync_unverified" do
    before :each do
      @user = build :user, :verified => false, :role_ids => []
      fake_login @user
    end

    it "should mark all children created as verified/unverifid based on the user" do
      @user.verified = true
      Child.should_receive(:new_with_user_name).with(@user, {"name" => "timmy", "verified" => @user.verified?}).and_return(child = Child.new)
      child.should_receive(:save).and_return true

      post :sync_unverified, {:child => {:name => "timmy"}, :format => :json}

      @user.verified = true
    end

    it "should set the created_by name to that of the user matching the params" do
      Child.should_receive(:new_with_user_name).and_return(child = Child.new)
      child.should_receive(:save).and_return true

      post :sync_unverified, {:child => {:name => "timmy"}, :format => :json}

      child['created_by_full_name'].should eq @user.full_name
    end

    it "should update the child instead of creating new child everytime" do
      Child.should_receive(:by_short_id).with(:key => '1234567').and_return(child = Child.new)
      controller.should_receive(:update_child_from).and_return(child)
      child.should_receive(:save).and_return true

      post :sync_unverified, {:child => {:name => "timmy", :unique_identifier => '12345671234567'}, :format => :json}

      child['created_by_full_name'].should eq @user.full_name
    end
  end

  describe "POST create" do
    it "should update the child record instead of creating if record already exists" do
      User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, {:name => 'old name'})
      child.save
      fake_admin_login
      controller.stub(:authorize!)
      post :create, :child => {:unique_identifier => child.unique_identifier, :name => 'new name'}
      updated_child = Child.by_short_id(:key => child.short_id)
      updated_child.size.should == 1
      updated_child.first.name.should == 'new name'
    end
  end

end
