
require 'spec_helper'

class MockFormSection
  def initialize is_valid = true
    @is_valid = is_valid
  end

  def valid?
    @is_valid
  end

  def create!
    FormSection.new
  end

  def unique_id
    "unique_id"
  end
end
describe FormSectionController do
  before do
    user = User.new(:user_name => 'manager_of_forms')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::FORMS[:manage]])])
    fake_login user
  end

  describe "get index" do
    it "populate the view with all the form sections in order ignoring enabled or disabled" do
      row1 = FormSection.new(:visible => false, :order => 1)
      row2 = FormSection.new(:visible => true, :order => 2)
      FormSection.stub!(:all).and_return([row1, row2])

      get :index

      assigns[:form_sections].should == [row1, row2]
    end
  end
  describe "post create" do
    it "should new form_section with order" do
      existing_count = FormSection.count
      form_section = {:name=>"name", :description=>"desc", :help_text=>"help text", :visible=>true}
      post :create, :form_section => form_section
      FormSection.count.should == existing_count + 1
    end

    it "sets flash notice if form section is valid and redirect_to edit page with a flash message" do
      FormSection.stub(:new_with_order).and_return(MockFormSection.new)
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      request.flash[:notice].should == "Form section successfully added"
      response.should redirect_to(edit_form_section_path("unique_id"))
    end

    it "does not set flash notice if form section is valid and render new" do
      FormSection.stub(:new_with_order).and_return(MockFormSection.new(false))
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      request.flash[:notice].should be_nil
      response.should render_template("new")
    end

    it "should assign view data if form section was not valid" do
      expected_form_section = MockFormSection.new(false)
      FormSection.stub(:new_with_order).and_return expected_form_section
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      assigns[:form_section].should == expected_form_section
    end
  end

  describe "post save_order" do
    after { FormSection.all.each &:destroy }

    it "should save the order of the forms" do
      form_one = FormSection.create(:unique_id => "first_form", :name => "first form", :order => 1)
      form_two = FormSection.create(:unique_id => "second_form", :name => "second form", :order => 2)
      form_three = FormSection.create(:unique_id => "third_form", :name => "third form", :order => 3)
      post :save_form_order, :ids => [form_three.unique_id, form_one.unique_id, form_two.unique_id]
      FormSection.get_by_unique_id(form_one.unique_id).order.should == 2
      FormSection.get_by_unique_id(form_two.unique_id).order.should == 3
      FormSection.get_by_unique_id(form_three.unique_id).order.should == 1
      response.should render_template(:text => "OK")
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
      response.should redirect_to(edit_form_section_path(form_section.unique_id))
    end

    it "should show errors if invalid" do
      form_section = FormSection.new
      params = {"some" => :params}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section)
      form_section.should_receive(:properties=).with(params)
      form_section.should_receive(:valid?).and_return(false)
      post :update, :form_section => params, :id => "form_1"
      response.should_not redirect_to(form_section_index_path)
      response.should render_template("edit")
    end
  end

  describe "post enable" do
    it "when called with value false disables only the selected form sections" do
      form_section1 = {:name=>"name1", :description=>"desc", :visible=>"true", :unique_id=>"form_1"}
      form_section2 = {:name=>"name2", :description=>"desc", :visible=>"true", :unique_id=>"form_2"}
      form_section3 = {:name=>"name3", :description=>"desc", :visible=>"true", :unique_id=>"form_3"}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section1)
      FormSection.should_receive(:get_by_unique_id).with("form_2").and_return(form_section2)
      form_section1.stub(:save!)
      form_section2.stub(:save!)
      form_section1.should_receive(:visible=).with(false)
      form_section2.should_receive(:visible=).with(false)
      form_section3.should_not_receive(:visible=).with(false)
      post :enable, :value => false, :sections => {"form_1" => 1, "form_2" => 1}, :controller => "form_section"
    end

    it "when called with value true enables only the selected form sections" do
      form_section1 = {:name=>"name1", :description=>"desc", :visible=>"false", :unique_id=>"form_1"}
      form_section2 = {:name=>"name2", :description=>"desc", :visible=>"true", :unique_id=>"form_2"}
      form_section3 = {:name=>"name3", :description=>"desc", :visible=>"true", :unique_id=>"form_3"}
      FormSection.should_receive(:get_by_unique_id).with("form_1").and_return(form_section1)
      FormSection.should_receive(:get_by_unique_id).with("form_2").and_return(form_section2)
      form_section1.should_receive(:visible=).with(true)
      form_section2.should_receive(:visible=).with(true)
      form_section3.should_not_receive(:visible=).with(true)
      form_section1.stub(:save!)
      form_section2.stub(:save!)
      post :enable, :value => true, :sections => {"form_1" => 1, "form_2" => 1}, :controller => "form_section"
    end
  end
end
