require 'spec_helper'

describe EnquiriesController do

  before :each do
    Enquiry.all.each{|enquiry| enquiry.destroy}
    fake_admin_login
  end

  def mock_enquiry(stubs={})
    @mock_enquiry ||= mock_model(Enquiry, stubs).as_null_object
  end

  describe '#authorizations' do
    describe 'collection' do
      it "GET index" do
        @controller.current_ability.should_receive(:can?).with(:index, Enquiry).and_return(false);
        get :index
        response.status.should == 403
      end

      it "GET new" do
        @controller.current_ability.should_receive(:can?).with(:create, Enquiry).and_return(false);
        get :new
        response.status.should == 403
      end

      it "POST create" do
        @controller.current_ability.should_receive(:can?).with(:create, Enquiry).and_return(false);
        post :create
        response.status.should == 403
      end

    end

    describe 'member' do
      before :each do
        User.stub!(:find_by_user_name).with("uname").and_return(user = mock('user', :user_name => 'uname', :organisation => 'org'))
        @enquiry = Enquiry.create(:enquirer_name => 'Someone', :criteria => {'name' => 'child name'})
        @enquiry_arg = hash_including("_id" => @enquiry.id)
      end

      it "GET show" do
        @controller.current_ability.should_receive(:can?).with(:read, @enquiry_arg).and_return(false);
        get :show, :id => @enquiry.id
        response.status.should == 403
      end
    end
  end

  describe "GET index" do

    describe "viewing enquiries by user with access to all data" do
      describe "when the signed in user has access all data" do
        before do
          fake_field_admin_login
          @options ||= {}
          @stubs ||= {}
        end

        it "should assign all enquiries as @enquiries" do
          page = @options.delete(:page)
          per_page = @options.delete(:per_page)
          enquiries = [mock_enquiry(@stubs)]
          @status ||= "all"
          @filter ||= "all"
          enquiries.stub!(:paginate).and_return(enquiries)
          @controller.current_ability.should_receive(:can?).with(:index, Enquiry).and_return(true);
          @controller.should_receive(:enquiries_by_user_access).and_return([1, enquiries])

          get :index, :status => @status
          assigns[:enquiries].should == enquiries
        end
      end
    end

  end

  describe "GET show" do

    it "assigns the requested enquiry" do
      Enquiry.stub!(:get).with("37").and_return(mock_enquiry)
      get :show, :id => "37"
      assigns[:enquiry].should equal(mock_enquiry)
    end

    it "orders and assigns the forms" do
      Enquiry.stub!(:get).with("37").and_return(mock_enquiry)
      @controller.should_receive(:get_form_sections).and_return([:the_form_sections])
      get :show, :id => "37"
      assigns[:form_sections].should == [:the_form_sections]
    end

    it "should flash an error and go to listing page if the resource is not found" do
      Enquiry.stub!(:get).with("invalid record").and_return(nil)
      get :show, :id=> "invalid record"
      flash[:error].should == "Enquiry with the given id is not found"
      response.should redirect_to(:action => :index)
    end

  end

  describe "GET new" do

    it "assigns a new enquiry as @enquiry" do
      Enquiry.stub!(:new).and_return(mock_enquiry)
      get :new
      assigns[:enquiry].should equal(mock_enquiry)
    end

    it "orders and assigns the forms" do
      Enquiry.stub!(:new).and_return(mock_enquiry)
      @controller.should_receive(:get_form_sections).and_return([:the_form_sections])
      get :new
      assigns[:form_sections].should == [:the_form_sections]
    end
    
  end

end
