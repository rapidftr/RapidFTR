require 'spec_helper'

describe SessionsController, :type => :routing do
  describe "routing" do

    it "recognizes and generates #new" do
      expect({ :get => "/sessions/new" }).to route_to(:controller => "sessions", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/sessions/1" }).to route_to(:controller => "sessions", :action => "show", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/sessions" }).to route_to(:controller => "sessions", :action => "create")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/sessions/1" }).to route_to(:controller => "sessions", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #active" do
      expect({ :get => "/active" }).to route_to(:controller => "sessions", :action => "active")
    end
  end
end
