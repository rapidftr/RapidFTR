require 'spec_helper'

describe ChildrenController do
  before do
    Clock.fake_time_now = Time.utc(2000, "jan", 1, 20, 15, 1)
    fake_login
  end

  after do
    Clock.reset!
  end

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs).as_null_object
  end

  before do
    FormSection.stub!(:all_child_field_names).and_return(["name", "age", "origin"])
  end

  describe "GET index" do
    it "assigns all childrens as @childrens" do
      Child.stub!(:all).and_return([mock_child])
      get :index
      assigns[:children].should == [mock_child]
    end
  end

  describe "GET show" do
    it "assigns the requested child as @child" do
      Child.stub!(:get).with("37").and_return(mock_child)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end

    it "orders the forms" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:all_by_order)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET new" do
    it "assigns a new child as @child" do
      Child.stub!(:new).and_return(mock_child)
      get :new
      assigns[:child].should equal(mock_child)
    end

    it "orders the forms" do
      Child.stub!(:new).and_return(mock_child)
      FormSection.should_receive(:all_by_order)
      get :new
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET edit" do
    it "assigns the requested child as @child" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:all_by_order)
      get :edit, :id => "37"
      assigns[:child].should equal(mock_child)
    end
    
    it "Orders the forms" do
      Child.stub!(:get).with("37").and_return(mock_child)
      FormSection.should_receive(:all_by_order)
      get :edit, :id => "37"
      assigns[:child].should equal(mock_child)
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

      current_time = Time.parse("Jan 17 2010 14:05:32")
      Time.stub!(:now).and_return current_time
      put :update, :id => child.id,
        :child => {
          :last_known_location => "Manchester",
          :photo => uploadable_photo_jeff }

      assigns[:child]['last_known_location'].should == "Manchester"
      assigns[:child]['_attachments'].size.should == 2
      assigns[:child]['_attachments']['photo-2010-01-17T140532']['data'].should_not be_blank
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

    it 'asks view to show thumbnails if show_thumbnails query parameter is present' do
      get(:search, :format => 'html',:show_thumbnails => '1',:query => "blah")
      assigns[:show_thumbnails].should == true
    end

    it 'asks view to not show thumbnails if show_thumbnails query parameter is missing' do
      get( :search, :format => 'html', :query => "blah" )
      assigns[:show_thumbnails].should == false
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
    
    it 'sends csv data with the correct content type and file name' do
      @controller.
        should_receive(:send_data).
        with( anything, :filename => 'rapidftr_search_results.csv', :type => 'text/csv' )
      get( :search, :format => 'csv', :query => 'blah')
    end

    describe 'CSV formatting' do
        
      def inject_results( results )
        Child.stub!(:search).and_return(results)
      end
    
      def csv_response
        get( :search, :format => 'csv', :query => 'blah' )
        response.body
      end

      def csv_export_data_response
        get( :export, :format => 'csv', :query => 'blah' )
        response.body
      end

      it 'should contain the correct column headers based on the defined fields' do
        inject_results([])
        first_line = csv_response.split("\n").first
        headers = first_line.split(",")

        FormSection.all_child_field_names.each {|field_name| headers.should contain field_name}
      end
    
      it 'should render a row for each result, plus a header row' do
        inject_results( [
          Child.new( 'name' => 'Dave' ),
          Child.new( 'name' => 'Mary' )
        ] );
        csv_response.split("\n").length.should == 3
      end
    
      it "should render each record's name and age correctly" do
        inject_results( [
          Child.new( 'name' => 'Dave', 'age' => 145, 'unique_identifier' => 'dave_xxx' ),
          Child.new( 'name' => 'Mary', 'age' => 12, 'unique_identifier' => 'mary_xxx' )
        ] );
        rows = csv_response.split("\n").map{ |line| line.split(",") }
        rows.shift # skip past header row
        rows.shift.should == ['dave_xxx', 'Dave','145']
        rows.shift.should == ['mary_xxx','Mary','12']
      end
    end
  end
  
  describe "GET advanced search" do
    
    it "should not render error by default" do
      get(:advanced_search, :format => 'html')
      assigns[:search].should be_nil
    end
    
    it "should define form section fields as search criteria" do
      names = []
      FormSection.stub!(:all_child_field_names).and_return(names)
      get(:advanced_search, :format => 'html')
      assigns[:fields_name].should == names
    end

    it "should assign results" do
      children = []
      search = mock(:search, :search_field => "field", :search_value => 'value', :valid? => true);
      AdvancedSearch.stub!(:new).and_return(search)
      Summary.should_receive(:advanced_search).with(search).and_return(children)
      get(:advanced_search, :format => 'html', :search_field => "field", :search_value => "value")
    end
    
    it "should render advanced search on success" do
      children = []
      Summary.should_receive(:advanced_search).and_return(children)
      get(:advanced_search, :format => 'html', :search_field => "field", :search_value => "value")
      response.should render_template("children/advanced_search")
    end
    
    it "should redirect to the child page if only one result is found" do
      children = [stub("Child", :to_param => '1235')]
      Summary.should_receive(:advanced_search).and_return(children)
      get(:advanced_search, :format => 'html', :search_field => "field", :search_value => "value")
      response.should redirect_to(child_path(children.first))
    end

    it "should render error if search is invalid" do
      get(:advanced_search, :format => 'html', :search_field => "", :search_value => "")
      search = assigns[:search]
      search.errors.size.should == 2
    end
    
  end

  describe "GET photo_pdf" do
    def inject_pdf_generator( fake_pdf_generator )
      PdfGenerator.stub!(:new).and_return( fake_pdf_generator )
    end

    def stub_out_pdf_generator
      inject_pdf_generator( stub_pdf_generator = stub(PdfGenerator) )
      stub_pdf_generator.stub!(:child_photos).and_return('')
      stub_pdf_generator
    end

    def stub_out_child_get(mock_child = mock(Child))
      Child.stub(:get).and_return( mock_child )
      mock_child
    end

    it 'extracts a single selected id from post params correctly' do
      stub_out_pdf_generator
      Child.should_receive(:get).with('a_child_id')
      post(
        :export_data,
        { 'a_child_id' => 'selected', 'some_other_post_param' => 'blah' }
      )
    end

    it 'extracts a multiple selected ids from post params correctly' do
      stub_out_pdf_generator
      Child.should_receive(:get).with('child_one')
      Child.should_receive(:get).with('child_two')
      Child.should_receive(:get).with('child_three')

      post(
        :export_data,
        {
          'child_one' => 'selected',
          'child_two' => 'selected',
          'child_three' => 'selected',
          'some_other_post_param' => 'blah'
        }
      )
    end


    it "asks the pdf generator to render each child" do
      inject_pdf_generator( mock_pdf_generator = mock(PdfGenerator) )

      Child.stub(:get).and_return( :fake_child_one, :fake_child_two )


      mock_pdf_generator.
        should_receive(:child_photos).
        with([:fake_child_one,:fake_child_two]).
        and_return('')

      post(
        :export_data,
        {
          'child_1' => 'selected',
          'child_2' => 'selected',
          :commit => "Export to PDF"
        }
      )
    end

    it "sends a response containing the pdf data, the correct content_type and file name, etc" do
      stub_pdf_generator = stub_out_pdf_generator
      stub_pdf_generator.stub!(:child_photos).and_return(:fake_pdf_data)
      stub_out_child_get

      @controller.stub!(:current_user_name).and_return('foo-user')

      @controller.
        should_receive(:send_data).
        with( :fake_pdf_data, :filename => "foo-user-20000101-2015.pdf", :type => "application/pdf" )

      post( :export_data, 'ignored' => 'selected', :commit => "Export to PDF" )
    end
  end
end
