require 'spec_helper'

describe ChildrenController do
  include LoggedIn

  def mock_child(stubs={})
    stubs.reverse_merge!('[]'=>nil)
    @mock_child ||= mock_model(Child, stubs)
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
  end

  describe "GET show with image content type" do
    it "outputs the image data from the child object" do
      photo_data = "somedata"
      Child.stub(:get).with("5363dhd").and_return(mock_child)
      mock_child.stub(:photo).and_return(photo_data)
      request.accept = "image/jpeg"

      get :show, :id => "5363dhd"

      response.body.should == "somedata"
      
    end
  end

  describe "GET new" do
    it "assigns a new child as @child" do
      Child.stub!(:new).and_return(mock_child)
      get :new
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET edit" do
    it "assigns the requested child as @child" do
      Child.stub!(:get).with("37").and_return(mock_child)
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
      
      current_time = Time.parse("Jan 17 2010 14:05")
      Time.stub!(:now).and_return current_time      
      put :update, :id => child.id, 
        :child => {
          :last_known_location => "Manchester", 
          :photo => uploadable_photo_jeff }

      assigns[:child]['last_known_location'].should == "Manchester"
      assigns[:child]['_attachments'].size.should == 2
      assigns[:child]['_attachments']['photo-17-01-2010-1405']['data'].should_not be_blank
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
    it "performs a search using the parameters passed to it" do
      fake_results = [:fake_child,:fake_child]
      Summary.should_receive(:basic_search).with( 'the child name', 'the_unique_id' ).and_return(fake_results)
      get( 
        :search,
        :format => 'html',
        :child_name => 'the child name',
        :unique_identifier => 'the_unique_id'
      )
      assigns[:results].should == fake_results
    end

    it 'asks view to show thumbnails if show_thumbnails query parameter is present' do
      get( 
        :search, 
        :format => 'html',
        :show_thumbnails => '1'
      )
      assigns[:show_thumbnails].should == true
    end

    it 'asks view to not show thumbnails if show_thumbnails query parameter is missing' do
      get( :search, :format => 'html' )
      assigns[:show_thumbnails].should == false
    end

    it 'asks view to not show csv export link if there are no results' do
      Summary.stub!(:basic_search).and_return([])
      get(:search, :format => 'html' )
      assigns[:show_csv_export_link].should == false
    end

    it 'sends csv data with the correct content type and file name' do
      @controller.
        should_receive(:send_data).
        with( anything, :filename => 'rapidftr_search_results.csv', :type => 'text/csv' )

      get( :search, :format => 'csv' )
    end
    
    describe 'CSV formatting' do

      def inject_results( results )
        Summary.stub!(:basic_search).and_return(results)
      end

      def csv_response
        get( :search, :format => 'csv' )
        response.body
      end

      it 'should contain the correct column headers' do
        inject_results([])
        first_line = csv_response.split("\n").first
        headers = first_line.split(",")

        headers.should == Templates.all_child_field_names 
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
          Child.new( 'name' => 'Dave', 'age' => 145 ),
          Child.new( 'name' => 'Mary', 'age' => 12 )
        ] );
        rows = csv_response.split("\n").map{ |line| line.split(",") }
        rows.shift # skip past header row
        rows.shift.should == ['Dave','145']
        rows.shift.should == ['Mary','12']
      end
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
        :photo_pdf, 
        { 'a_child_id' => 'selected', 'some_other_post_param' => 'blah' } 
      )
    end

    it 'extracts a multiple selected ids from post params correctly' do
      stub_out_pdf_generator
      Child.should_receive(:get).with('child_one')
      Child.should_receive(:get).with('child_two')
      Child.should_receive(:get).with('child_three')

      post( 
        :photo_pdf, 
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
        :photo_pdf, 
        { 
          'child_1' => 'selected', 
          'child_2' => 'selected', 
        } 
      )
    end

    it "sends a response containing the pdf data, the correct content_type, etc" do
      stub_pdf_generator = stub_out_pdf_generator
      stub_pdf_generator.stub!(:child_photos).and_return(:fake_pdf_data)
      stub_out_child_get

      @controller.
        should_receive(:send_data).
        with( :fake_pdf_data, :filename => "photos.pdf", :type => "application/pdf" )

      post( :photo_pdf, 'ignored' => 'selected' )
    end
  end
end
