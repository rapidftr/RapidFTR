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

  before do
    fake_admin_login
  end

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs).as_null_object
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

      it "GET export_data" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        get :export_data
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
        @child = Child.create('last_known_location' => "London")
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
        it "should assign all childrens as @childrens" do
          session = fake_field_admin_login

          @stubs ||= {}
          children = [mock_child(@stubs)]
          Child.should_receive(:all).and_return(children)
          get :index, :status => @status
          assigns[:children].should == children
        end
      end
    end

    shared_examples_for "viewing children as a field worker" do
      describe "when the signed in user is a field worker" do
        it "should assign the children created by the user as @childrens" do
          session = fake_field_worker_login

          @stubs ||= {}
          children = [mock_child(@stubs)]
          Child.should_receive(:all_by_creator).with(session.user_name).and_return(children)
          get :index, :status => @status
          assigns[:children].should == children
        end
      end
    end

    context "as administrator" do
      it "should assign all the children" do
        session = fake_admin_login
        children = [mock_child, mock_child]
        Child.should_receive(:all).and_return(children)
        get :index, :status => 'reunited'
        assigns[:children].should == children
      end
    end

    context "viewing all children" do
      context "when status is passed" do
        before { @status = "all" }
        it_should_behave_like "viewing children by user with access to all data"
        it_should_behave_like "viewing children as a field worker"
      end

      context "when status is not passed" do
        it_should_behave_like "viewing children by user with access to all data"
        it_should_behave_like "viewing children as a field worker"
      end
    end

    context "viewing reunited children" do
      before { @status = "reunited" }
      it_should_behave_like "viewing children by user with access to all data"
      it_should_behave_like "viewing children as a field worker"
    end

    context "viewing flagged children" do
      before { @status = "flagged" }
      it_should_behave_like "viewing children by user with access to all data"
      it_should_behave_like "viewing children as a field worker"
    end

    context "viewing active children" do
      before do
        @status = "active"
        @stubs = {:reunited? => false}
      end
      it_should_behave_like "viewing children by user with access to all data"
      it_should_behave_like "viewing children as a field worker"
    end
  end

  describe "GET show" do
    it "assigns the requested child" do
      Child.stub!(:get).with("37").and_return(mock_child)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end

    it 'should not fail if primary_photo_id is not present' do
      child = Child.create('last_known_location' => "London")
      Child.stub!(:get).with("37").and_return(child)
      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))

      get(:show, :format => 'csv', :id => "37")
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
    it "should update child on a field and photo update" do
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo)

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
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo)

      put :update, :id => child.id,
        :child => {
          :last_known_location => "Manchester",
          :age => '7'}

      assigns[:child]['last_known_location'].should == "Manchester"
      assigns[:child]['age'].should == "7"
      assigns[:child]['_attachments'].size.should == 1
    end

    it "should not update history on photo rotation" do
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo_jeff)

      put :update_photo, :id => child.id, :child => {:photo_orientation => "-180"}

      Child.get(child.id)["histories"].should be_empty
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
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo)
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
      child = Child.create('last_known_location' => "London", 'photo' => uploadable_photo_jeff)

      put :update, :id => child.id, :child => {:flag => true, :flag_message => "Test"}

      history = Child.get(child.id)["histories"].first
      history['changes'].should have_key('flag')
      history['datetime'].should == "2010-01-20 17:10:32UTC"
    end

    it "should update the last_updated_by_full_name field with the logged in user full name" do
      child = Child.create('name' => "Existing Child")
      Child.stub(:get).with(child.id).and_return(child)
      subject.should_receive('current_user_full_name').any_number_of_times.and_return('Bill Clinton')
      put :update, :id => child.id, :child => {:flag => true, :flag_message => "Test"}
      child['last_updated_by_full_name'].should=='Bill Clinton'
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
      search = mock("search", :query => 'the child name', :valid? => true)
      Search.stub!(:new).and_return(search)

      fake_results = [:fake_child,:fake_child]
      Child.should_receive(:search).with(search).and_return(fake_results)
      get(:search, :format => 'html', :query => 'the child name')
      assigns[:results].should == fake_results
    end

    it "asks the pdf generator to render each child as a PDF" do
      Clock.stub!(:now).and_return(Time.parse("Jan 01 2000 20:15").utc)
			children = [:fake_child_one, :fake_child_two]
      Child.stub(:get).and_return(:fake_child_one, :fake_child_two)

			inject_export_generator( mock_export_generator = mock(ExportGenerator), children )
      mock_export_generator.should_receive(:to_full_pdf).and_return('')

      post :export_data,{:selections =>{'0' => 'child_1','1' => 'child_2'},:commit => "Export to PDF"}
    end

    it "asks the pdf generator to render each child as a Photo Wall" do
      Clock.stub!(:now).and_return(Time.parse("Jan 01 2000 20:15").utc)
      children = [:fake_one, :fake_two]
      inject_export_generator( mock_export_generator = mock(ExportGenerator), children )
      Child.stub(:get).and_return(*children )

      mock_export_generator.should_receive(:to_photowall_pdf).and_return('')

      post :export_data,{:selections =>{'0' => 'child_1','1' => 'child_2'},:commit => "Export to Photo Wall"}
    end

    describe "with no results" do
      before do
        Summary.stub!(:basic_search).and_return([])
        get(:search,  :query => 'blah'  )
      end

      it 'asks view to not show csv export link if there are no results' do
        assigns[:results].size.should == 0
      end

      it 'asks view to display a "No results found" message if there are no results' do
        assigns[:results].size.should == 0
      end

    end

    it 'sends csv data with the correct attributes' do
			Child.stub!(:search).and_return([])
			export_generator = stub(ExportGenerator)
			inject_export_generator(export_generator, [])

			export_generator.should_receive(:to_csv).and_return(ExportGenerator::Export.new(:csv_data, {:foo=>:bar}))
			@controller.
        should_receive(:send_data).
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
      search = mock("search", :query => 'some_name', :valid? => true)
      Search.stub!(:new).and_return(search)

      fake_results = [:fake_child,:fake_child]
      Child.should_receive(:search_by_created_user).with(search, @session.user_name).and_return(fake_results)

      get(:search, :query => 'some_name')
      assigns[:results].should == fake_results
    end
  end
  describe "GET photo_pdf" do

    it 'extracts multiple selected ids from post params in correct order' do
      stub_out_export_generator
      Child.should_receive(:get).with('child_zero').ordered
      Child.should_receive(:get).with('child_one').ordered
      Child.should_receive(:get).with('child_two').ordered
      controller.stub!(:render) #to avoid looking for a template

      post :export_data, :selections =>{'2' => 'child_two','0' => 'child_zero','1' => 'child_one'}
    end

    it "sends a response containing the pdf data, the correct content_type and file name, etc" do
      Clock.stub!(:now).and_return(Time.utc(2000, 1, 1, 20, 15))

			stubbed_child = stub_out_child_get
      stub_export_generator = stub_out_export_generator [stubbed_child] #this is getting a bit farcical now
      stub_export_generator.stub!(:to_photowall_pdf).and_return(:fake_pdf_data)

      @controller.
        should_receive(:send_data).
        with( :fake_pdf_data, :filename => "fakeadmin-20000101-2015.pdf", :type => "application/pdf" ).
        and_return{controller.render :nothing => true}

      post( :export_data, :selections => {'0' => 'ignored'}, :commit => "Export to Photo Wall" )
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
      Child.should_receive(:get).with('1').and_return(
        stub_child = stub('child', :unique_identifier => '1', :class => Child))

      ExportGenerator.should_receive(:new).and_return(export_generator = mock('export_generator'))
      export_generator.should_receive(:to_photowall_pdf).and_return(:fake_pdf_data)

      @controller.
        should_receive(:send_data).
        with(:fake_pdf_data, :filename => '1-20000101-0915.pdf', :type => 'application/pdf').
        and_return{controller.render :nothing => true}

      get :export_photo_to_pdf, :id => '1'
    end
  end

  describe "PUT select_primary_photo" do
    before :each do
      @child = mock(Child, :id => :id)
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

end
