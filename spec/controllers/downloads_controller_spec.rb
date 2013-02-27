  require 'spec_helper'

def inject_export_generator( fake_export_generator, child_data )
  ExportGenerator.stub!(:new).with(encryption_options, child_data).and_return( fake_export_generator )
end

def stub_out_export_generator child_data = []
  inject_export_generator( stub_export_generator = stub(ExportGenerator), child_data)
  stub_export_generator.stub!(:child_photos).and_return('')
  stub_export_generator
end


def stub_out_child_get(mock_child = mock(Child))
  Child.stub(:get).and_return( mock_child )
  mock_child
end

def encryption_options
  {:encryption_options => {:user_password=>"password", :owner_password=>"password"}}
end

describe DownloadsController do

  before :each do
    fake_admin_login
  end

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs).as_null_object
  end

  describe '#authorizations' do
    describe 'collection' do
      it "POST children_data" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :children_data
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "POST child_data" do
        Child.stub!(:get).with("id").and_return(mock_child)
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :child_data, {:id => "id", :password => "password"}
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "POST child_photo" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :child_photo, :id => "id"
        response.should render_template("#{Rails.root}/public/403.html")
      end

      it "POST children_record" do
        @controller.current_ability.should_receive(:can?).with(:export, Child).and_return(false);
        post :children_record
        response.should render_template("#{Rails.root}/public/403.html")
      end

    end
  end

  describe "POST children_data" do
    describe "when the signed in user has access all data" do
      before do
        fake_admin_login
        @stubs ||= {}
      end

      it "should assign all childrens as @childrens" do
        children = [mock_child(@stubs)]
        @status = "all"

        Child.should_receive(:view).with(:by_all_view, :startkey => [@status], :endkey => [@status , {}]).and_return(children)

        post :children_data, { :password => "password" }
        assigns[:children].should == children
      end
    end
  end

  describe "POST child_data" do
      describe "when the signed in user has access to export data" do
        before do
          fake_admin_login
          @stubs ||= {}
        end

        it "assigns the requested child" do
          Child.stub!(:get).with("3").and_return(mock_child)
          post :child_data, {:id => "3", :password => "password"}
          assigns[:child].should equal(mock_child)
        end

        it "should flash an error and go to listing page if the resource is not found" do
          Child.stub!(:get).with("invalid record").and_return(nil)
          post :child_data, {:id=> "invalid record", :password => "password" }
          flash[:error].should == "Child with the given id is not found"
          response.should redirect_to(:action => :index, :controller => :children)
        end
      end
  end



  describe "POST children_record" do

    it "extracts multiple selected ids from post params in correct order" do
      stub_out_export_generator
      Child.should_receive(:get).with('child_zero').ordered
      Child.should_receive(:get).with('child_one').ordered
      Child.should_receive(:get).with('child_two').ordered
      controller.stub!(:render)

      post :children_record, {:selections =>{'2' => 'child_two','0' => 'child_zero','1' => 'child_one'}, :password => "password", :format => "pdf"}
    end

    it "sends a response containing the pdf data, the correct content_type and file name, etc" do
      Clock.stub!(:now).and_return(Time.utc(2000, 1, 1, 20, 15))

      stubbed_child = stub_out_child_get
      stub_export_generator = stub_out_export_generator [stubbed_child]
      stub_export_generator.stub!(:to_photowall_pdf).and_return(:fake_pdf_data)

      @controller.
          should_receive(:send_data).
          with( :fake_pdf_data, :filename => "fakeadmin-20000101-2015.pdf", :type => "application/pdf" ).
          and_return{controller.render :nothing => true}

      post( :children_record, {:selections => {'0' => 'ignored'}, :commit => "Export to Photo Wall" , :password => "password", :format => "pdf"})
    end

    it "asks the pdf generator to render each child as a PDF" do
      Clock.stub!(:now).and_return(Time.parse("Jan 01 2000 20:15").utc)
      children = [:fake_child_one, :fake_child_two]
      Child.stub(:get).and_return(:fake_child_one, :fake_child_two)

      inject_export_generator( mock_export_generator = mock(ExportGenerator), children )
      mock_export_generator.should_receive(:to_full_pdf).and_return('')

      post :children_record,{:selections =>{'0' => 'child_1','1' => 'child_2'},:commit => "Export to PDF", :password => "password", :format => "pdf"}
    end

    it "asks the pdf generator to render each child as a Photo Wall" do
      Clock.stub!(:now).and_return(Time.parse("Jan 01 2000 20:15").utc)
      children = [:fake_one, :fake_two]
      inject_export_generator( mock_export_generator = mock(ExportGenerator), children )
      Child.stub(:get).and_return(*children )

      mock_export_generator.should_receive(:to_photowall_pdf).and_return('')

      post :children_record,{:selections =>{'0' => 'child_1','1' => 'child_2'},:commit => "Export to Photo Wall",:password => "password", :format => "pdf"}
    end
  end

  describe "POST child_photo" do

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
          should_receive(:send_data).
          with(:fake_pdf_data, :filename => '1-20000101-0915.pdf', :type => 'application/pdf').
          and_return{controller.render :nothing => true}

      post :child_photo, {:id => '1', :password => "password", :format => "pdf"}
    end
  end
end