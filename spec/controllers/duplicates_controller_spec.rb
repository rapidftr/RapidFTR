require 'spec_helper'

describe DuplicatesController do
  include FakeLogin
  
  describe "GET new" do
    context "An admin user with a valid non-duplicate child id" do
      before :each do
        fake_admin_login
        
        @child = mock_model(Child, :name => "John")
        Child.stub!(:get).with("1234").and_return(@child)
        
        @form_sections = [ mock_model(FormSection), mock_model(FormSection), mock_model(FormSection) ]
        
        get :new, :child_id => "1234"
      end
      
      it "should be successful" do
        response.should be_success
      end
      
      it "should fetch and assign the child" do
        assigns[:child].should equal(@child)
      end
      
      it "should assign the page name" do
        assigns[:page_name].should == "Mark #{@child.name} as Duplicate"
      end
    end
    
    context "An non-admin user" do
      before :each do
        fake_login
        get :new, :child_id => "1234"
      end
      
      it "should get forbidden response" do
        response.response_code.should == 403
      end
    end
    
    context "An admin user with a non-valid child id" do
      it "should redirect to flagged children page" do
        fake_admin_login        
        get :new, :child_id => "not_a_valid_child_id"
        response.should redirect_to(child_filter_path("flagged"))
      end
    end
  end
  
  describe "POST create" do
    context "An admin user with a valid non-duplicate child id" do
      before :each do
        fake_admin_login        
        @child = Child.new
        @child.stub!(:save)
      end
      
      it "should mark the child as duplicate" do
        fake_admin_login
        
        Child.stub!(:get).with("1234").and_return(@child)
        
        @child.should_receive(:mark_as_duplicate).with("5678")        
        
        post :create, :child_id => "1234", :parent_id => "5678"        
      end
      
      it "should redirect to the duplicated child view" do
        
        Child.stub!(:get).and_return(@child)
        @child.stub!(:mark_as_duplicate)
        
        post :create, :child_id => "1234", :parent_id => "5678"
        
        response.response_code.should == 302
      end
    end
  end  
end
