require 'spec_helper'

describe ChildrenController do

  def mock_child(stubs={})
    @mock_child ||= mock_model(Child, stubs)
  end

  describe "GET index" do
    it "assigns all childrens as @childrens" do
      Child.stub!(:find).with(:all).and_return([mock_child])
      get :index
      assigns[:children].should == [mock_child]
    end
  end

  describe "GET show" do
    it "assigns the requested child as @child" do
      Child.stub!(:find).with("37").and_return(mock_child)
      get :show, :id => "37"
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET new" do
    it "assigns a new child as @child" do
      Child.stub!(:new).and_return(mock_child)
      get :new
      assigns[:child].should equal(mock_child)
    end
  end

  describe "GET edit" do
    it "assigns the requested child as @child" do
      Child.stub!(:find).with("37").and_return(mock_child)
      get :edit, :id => "37"
      assigns[:child].should equal(mock_child)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created child as @child" do
        Child.stub!(:new).with({'these' => 'params'}).and_return(mock_child(:save => true))
        post :create, :child => {:these => 'params'}
        assigns[:child].should equal(mock_child)
      end

      it "redirects to the created child" do
        Child.stub!(:new).and_return(mock_child(:save => true))
        post :create, :child => {}
        response.should redirect_to(child_url(mock_child))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved child as @child" do
        Child.stub!(:new).with({'these' => 'params'}).and_return(mock_child(:save => false))
        post :create, :child => {:these => 'params'}
        assigns[:child].should equal(mock_child)
      end

      it "re-renders the 'new' template" do
        Child.stub!(:new).and_return(mock_child(:save => false))
        post :create, :child => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested child" do
        Child.should_receive(:find).with("37").and_return(mock_child)
        mock_child.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :child => {:these => 'params'}
      end

      it "assigns the requested child as @child" do
        Child.stub!(:find).and_return(mock_child(:update_attributes => true))
        put :update, :id => "1"
        assigns[:child].should equal(mock_child)
      end

      it "redirects to the child" do
        Child.stub!(:find).and_return(mock_child(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(child_url(mock_child))
      end
    end

    describe "with invalid params" do
      it "updates the requested child" do
        Child.should_receive(:find).with("37").and_return(mock_child)
        mock_child.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :child => {:these => 'params'}
      end

      it "assigns the child as @child" do
        Child.stub!(:find).and_return(mock_child(:update_attributes => false))
        put :update, :id => "1"
        assigns[:child].should equal(mock_child)
      end

      it "re-renders the 'edit' template" do
        Child.stub!(:find).and_return(mock_child(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
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
