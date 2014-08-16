require 'spec_helper'

describe ChildrenController, :type => :routing do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "/children" }).to route_to(:controller => "children", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/children/new" }).to route_to(:controller => "children", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/children/1" }).to route_to(:controller => "children", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/children/1/edit" }).to route_to(:controller => "children", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/children" }).to route_to(:controller => "children", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/children/1" }).to route_to(:controller => "children", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/children/1" }).to route_to(:controller => "children", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #search" do
      expect({ :get => '/children/search' }).to route_to(:controller => 'children', :action => 'search')
    end

    it 'handles a multi-child export request' do
      expect({ :post => 'advanced_search/export_data' }).to route_to( :controller => 'advanced_search', :action => 'export_data' )
    end
  end
end
