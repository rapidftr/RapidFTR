require 'spec_helper'
require 'support/child_builder'

describe ChildIdsController do

  include ChildBuilder

  before do
    fake_login
  end

  describe "routing" do
    it "should have a route retrieving all child Id and Rev pairs" do
      {:get => "/children-ids"}.should route_to(:controller => "child_ids", :action => "all")
    end
  end

  describe "response" do
    it "should return Id and Rev for each child record" do
      given_a_child.with_id("child-id").with_rev("child-revision-id")

      get :all

      response.headers['Content-Type'].should include("application/json")

      child_ids = JSON.parse(response.body)
      child_ids.length.should == 1

      child_id = child_ids[0]
      child_id['_id'].should == "child-id"
      child_id['_rev'].should == "child-revision-id"
    end
  end
end
