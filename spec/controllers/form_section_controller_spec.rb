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
  before do
    fake_admin_login
  end
  describe "get index" do
    it "populate the view with all the form sections" do
      expected_form_sections = [FormSection.new(name => "Form section 1"), FormSection.new(name => "Form section 2")]
      FormSection.stub!(:all_by_order).and_return(expected_form_sections)
      get :index
      assigns[:form_sections].should == expected_form_sections
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
      response.should redirect_to(formsections_path)
    end
    it "should show new view again if form section was not valid" do
      FormSection.stub(:create_new_custom).and_return MockFormSection.new(false)
      form_section = {:name=>"name", :description=>"desc", :enabled=>"true"}
      post :create, :form_section =>form_section
      response.should_not redirect_to(formsections_path)
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
   
  describe "post save_order" do
    it "should save the order of the forms" do
      form_one = FormSection.create(:unique_id => "first_form", :name => "first form", :order => 1)
      form_two = FormSection.create(:unique_id => "second_form", :name => "second form", :order => 2)
      form_three = FormSection.create(:unique_id => "third_form", :name => "third form", :order => 3)
      post :save_order, :form_order => {form_one.unique_id.to_s => "3", form_two.unique_id.to_s => "1", form_three.unique_id.to_s => "2"}
      FormSection.get_by_unique_id(form_one.unique_id).order.should == 3
      FormSection.get_by_unique_id(form_two.unique_id).order.should == 1
      FormSection.get_by_unique_id(form_three.unique_id).order.should == 2
    end
  end
  
  describe "post update" do
    it "should save update if valid" do
      form_section = FormSection.new
      params = {"some" => :params}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section)
      form_section.should_receive(:properties=).with(params)
      form_section.should_receive(:valid?).and_return(true)
      form_section.should_receive(:save!)
      post :update, :form_section => params, :id => "form_1"
      response.should redirect_to(formsections_path)
    end
    
    it "should show errors if invalid" do
      form_section = FormSection.new
      params = {"some" => :params}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section)
      form_section.should_receive(:properties=).with(params)
      form_section.should_receive(:valid?).and_return(false)
      post :update, :form_section => params, :id => "form_1"
      response.should_not redirect_to(formsections_path)
      response.should render_template("edit")
    end
  end
  
  describe "post enable" do
    it "when called with value false disables only the selected form sections" do
      form_section1 = {:name=>"name1", :description=>"desc", :enabled=>"true", :unique_id=>"form_1"}
      form_section2 = {:name=>"name2", :description=>"desc", :enabled=>"true", :unique_id=>"form_2"}
      form_section3 = {:name=>"name3", :description=>"desc", :enabled=>"true", :unique_id=>"form_3"}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section1)
      FormSection.should_receive(:get_by_unique_id).with("form_2").and_return(form_section2)
      form_section1.stub(:save!)
      form_section2.stub(:save!)
      form_section1.should_receive(:enabled=).with(false)
      form_section2.should_receive(:enabled=).with(false)
      form_section3.should_not_receive(:enabled=).with(false)
      post :enable, :value => false, :sections => {"form_1" => 1, "form_2" => 1}, :controller => "form_section"
    end

    it "when called with value true enables only the selected form sections" do
      form_section1 = {:name=>"name1", :description=>"desc", :enabled=>"false", :unique_id=>"form_1"}
      form_section2 = {:name=>"name2", :description=>"desc", :enabled=>"true", :unique_id=>"form_2"}
      form_section3 = {:name=>"name3", :description=>"desc", :enabled=>"true", :unique_id=>"form_3"}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section1)
      FormSection.should_receive(:get_by_unique_id).with("form_2").and_return(form_section2)
      form_section1.should_receive(:enabled=).with(true)
      form_section2.should_receive(:enabled=).with(true)
      form_section3.should_not_receive(:enabled=).with(true)
      form_section1.stub(:save!)
      form_section2.stub(:save!)
      post :enable, :value => true, :sections => {"form_1" => 1, "form_2" => 1}, :controller => "form_section"
    end
  end
end
