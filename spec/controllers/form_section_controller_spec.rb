require 'spec_helper'

class MockFormSection 
  def initialize is_valid = true
    @is_valid = is_valid
  end
  def valid?
    @is_valid 
  end
end
describe FormSectionController do
   describe "get index" do
     it "populate the view with all the form sections" do
      expected_form_sections = [FormSection.new(name => "Form section 1"), FormSection.new(name => "Form section 2")]
      FormSection.stub!(:all).and_return(expected_form_sections)
      get :index
      assigns[:form_sections].should == expected_form_sections
     end
     it "orders the form sections by their display order" do
      expected_form_sections = [FormSection.new(name => "Form section 2", :order=>2), FormSection.new(name => "Form section 1", :order=>1)]
      FormSection.stub!(:all).and_return(expected_form_sections)
      get :index
      assigns[:form_sections][0].should == expected_form_sections[1]
      assigns[:form_sections][1].should == expected_form_sections[0]
     end
   end
   describe "post create" do
     it "calls create_new_custom with parameters from post" do 
       FormSection.should_receive(:create_new_custom).with("name", "desc", true).and_return(MockFormSection.new)
       form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
       post :create, :form_section =>form_section
     end
    it "sets flash notice if form section is valid" do
      FormSection.stub(:create_new_custom).and_return(MockFormSection.new)
      form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
      post :create, :form_section =>form_section
      response.flash[:notice].should == "Form section successfully added"
    end
    it "does not set flash notice if form section is valid" do
      FormSection.stub(:create_new_custom).and_return(MockFormSection.new(false))
      form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
      post :create, :form_section =>form_section
      response.flash[:notice].should be_nil
    end
    it "should redirect back to the form sections page if form section is valid" do
      FormSection.stub(:create_new_custom).and_return(MockFormSection.new)
      form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
      post :create, :form_section =>form_section
      response.should redirect_to formsections_path
     end
     it "should show new view again if form section was not valid" do
       FormSection.stub(:create_new_custom).and_return MockFormSection.new(false)
       form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
       post :create, :form_section =>form_section
       response.should_not redirect_to formsections_path
       response.should render_template("new")
     end
      it "should assign view data if form section was not valid" do
        expected_form_section = MockFormSection.new(false)
        FormSection.stub(:create_new_custom).and_return expected_form_section
        form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
        post :create, :form_section =>form_section
        assigns[:form_section].should == expected_form_section
      end
   end
end
