require "spec_helper"

describe "Createing a new search request" do

  it "should set the id to the user name" do
    user_name = "someuser"
    request = SearchRequest.new user_name
    request.id.should == user_name
  end

  it "should save subsequent search request over previous search requests" do
    user_name = "zubair"
    request = SearchRequest.create_search(user_name, 'value' => 'willis')# SearchRequest.create_search(user_name, 'value' => 'willis')
    request.save
    request = SearchRequest.create_search(user_name, 'value' => 'value')
    request.save

    loaded_request = SearchRequest.get(user_name)

    loaded_request['value'].should == 'value'
  end

end