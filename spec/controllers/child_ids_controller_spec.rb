require 'spec_helper'
require 'support/child_builder'

describe ChildIdsController, :type => :controller do

  include ChildBuilder

  before do
    fake_login
  end

  describe "routing" do
    it "should have a route retrieving all child Id and Rev pairs" do
      expect(:get => "/children-ids").to route_to(:controller => "child_ids", :action => "all")
    end
  end

  describe "response" do
    it "should return Id and Rev for each child record" do
      given_a_child.with_id("child-id").with_rev("child-revision-id")
      expect(Child).to receive(:fetch_all_ids_and_revs).and_return([{"_id" => "child-id", "_rev" => "child-revision-id"}])

      get :all

      expect(response.headers['Content-Type']).to include("application/json")

      child_ids = JSON.parse(response.body)
      expect(child_ids.length).to eq(1)

      child_id = child_ids[0]
      expect(child_id['_id']).to eq("child-id")
      expect(child_id['_rev']).to eq("child-revision-id")
    end
  end
end
