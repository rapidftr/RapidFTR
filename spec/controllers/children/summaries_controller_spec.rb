require 'spec_helper'

describe Children::SummariesController, "POST create" do

  before(:each) do
    @user = User.new
    @user.user_name = "ausername"
    ApplicationController.stub(:current_user).and_return(@user)
    @search_request_params = {"name"=> "Willis"}
  end

  def post_request
    post :create, :search_request => @search_request_params
  end

  it "creates a new seach request for the user" do
    SearchRequest.should_receive(:new).with(@search_request_params)
    post_request
  end
  
  it "saves the search request for the user"  do
    search_request = stub('SearchRequest')

    SearchRequest.stub(:new).with(@user.user_name, @search_request_params).and_return(search_request)
    search_request.should_receive(:save)
    post_request

  end

  it "redirects to the summaries view" do
    search_result = stub('search_result')
    SearchRequest.stub(:new).with(anything, anything).and_return(search_result)
    search_result.should_receive(:save)
    
    post_request

    response.should redirect_to("/children/summary")
  end
end
