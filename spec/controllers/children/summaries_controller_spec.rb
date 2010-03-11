require 'spec_helper'

describe Children::SummariesController, "POST create" do
  include LoggedIn

  before(:each) do
    @user = User.new
    @user.user_name = "ausername"
    ApplicationController.stub(:current_user).and_return(@user)
    @search_request_params = {"child_name"=> "Willis"}
  end

  def post_request
    post :create, :search_params => @search_request_params
  end
  
  it "creates and saves the search request for the user"  do
    search_request = stub('search_request')

    SearchRequest.
      stub(:create_search).
      with(@user.user_name, hash_including(@search_request_params)).
      and_return(search_request)
    search_request.should_receive(:save)
    post_request
  end

  it "interprets no 'show_thumbnails' param to be false" do
    @search_request_params.delete('show_thumbnails')
    SearchRequest.should_receive(:create_search).with(
      anything,
      hash_including(:show_thumbnails => false)
    ).and_return( stub( 'search_request', :save => nil ) )

    post_request
  end
  
  it "interprets any 'show_thumbnails' param to be true" do
    @search_request_params['show_thumbnails'] = 'ffooo'
    SearchRequest.should_receive(:create_search).with(
      anything,
      hash_including(:show_thumbnails => true)
    ).and_return( stub( 'search_request', :save => nil ) )

    post_request
  end

  it "redirects to the summaries view" do
    search_result = double('search_result').as_null_object
    SearchRequest.stub(:new).with(anything).and_return(search_result)
    search_result.should_receive(:save)
    
    post_request

    response.should redirect_to("/children/summary")
  end
end

describe Children::SummariesController, "GET show" do
  include LoggedIn

  before :each do
    @user_name = 'zubair'
    @user = stub('user_stub')
    @user.stub(:user_name).and_return(@user_name)
    ApplicationController.stub(:current_user).and_return(@user)
    @search_params = SearchRequest.create_search(@user_name, {'child_name' => "jorge", 'unique_identifier' => "zubair",'show_thumbnails' => true})
    SearchRequest.stub(:get).with(@user_name).and_return(@search_params)
  end

  it "sets the results of the search to variable results" do
    fake_results = [:fake_child_1,:fake_child_2]
    Summary.should_receive(:basic_search).with(@search_params[:child_name], @search_params[:unique_identifier]).and_return(fake_results)
    get :show
    assigns[:results].should == fake_results
  end

  it "assigns the search parameters to instance variables so the search fields can be filled in" do
    get :show
    assigns[:prev_child_name].should == 'jorge'
    assigns[:prev_unique_identifier].should == 'zubair'
    assigns[:show_thumbnails].should == true
  end
  
  it "redirects to a child resource if there is only one result from the search" do
    single_child = Summary.new(:_id=>'some_id') 
    search_request = SearchRequest.create_search(@user_name, {'child_name' => "jorge", 'unique_identifier' => "zubair"})
    search_request.stub(:get_results).and_return([single_child])
    SearchRequest.stub(:get).and_return(search_request)

    get :show
    
    expected_redirect_url = child_path(single_child) 
    response.should redirect_to( expected_redirect_url ) 
  end
end
