require 'spec_helper'

describe ChildrenController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/children" }.should route_to(:controller => "children", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/children/new" }.should route_to(:controller => "children", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/children/1" }.should route_to(:controller => "children", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/children/1/edit" }.should route_to(:controller => "children", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/children" }.should route_to(:controller => "children", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/children/1" }.should route_to(:controller => "children", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/children/1" }.should route_to(:controller => "children", :action => "destroy", :id => "1") 
    end

    it "recognizes and generates #search" do
      { :get => '/children/search' }.should route_to(:controller => 'children', :action => 'search')
    end

    it 'handles a multi-child photo pdf request' do
      { :get => 'children/1;2;3/photo_pdf' }.should route_to( :controller => 'children', :action => 'photo_pdf', :id => '1;2;3' )
    end
  end
end
