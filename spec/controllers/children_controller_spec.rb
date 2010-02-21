require 'spec_helper'

describe ChildrenController do


  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs)
  end

  describe "GET index" do
    it "assigns all childrens as @childrens" do
      Child.stub!(:all).and_return([mock_child])
      get :index
      assigns[:children].should == [mock_child]
    end
  end

  describe "GET show" do
    it "assigns the requested child as @child" do
      pending
      Child.stub!(:get).with("37").and_return(mock_child)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET show with image content type" do
    it "outputs the image data from the child object" do
      pending
      photo_data = "somedata"
      Child.stub(:get).with("5363dhd").and_return(mock_child)
      mock_child.stub(:photo).and_return(photo_data)
      request.accept = "image/jpeg"

      get :show, :id => "5363dhd"

      response.body.should == "somedata"
      
    end
  end

  describe "GET new" do
    it "assigns a new child as @child" do
      pending
      Child.stub!(:new).and_return(mock_child)
      get :new
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET edit" do
    it "assigns the requested child as @child" do
      pending
      Child.stub!(:find).with("37").and_return(mock_child)
      get :edit, :id => "37"
      assigns[:child].should equal(mock_child)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested child" do
      Child.should_receive(:find).with("37").and_return(mock_child)
      mock_child.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the children list" do
      Child.stub!(:find).and_return(mock_child(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(children_url)
    end
  end

end
