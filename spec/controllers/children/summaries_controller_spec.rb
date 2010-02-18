require 'spec_helper'

describe Children::SummariesController, "POST create" do

  before(:each) do
    @search_request = {"name"=> "Willis"}
  end

  after(:each) do
    post :create, :search_request => @search_request
  end

  it "creates a new seach request for the user" do
    SearchRequest.should_receive(:new).with(@search_request)
  end
  
  it "saves the search request for the user"

  it "redirects to the summaries view"
end
