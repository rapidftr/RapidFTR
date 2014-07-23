require 'spec_helper'

class MockFormSection

  def initialize is_valid = true
    @is_valid = is_valid
  end

  def base_language= base_language
    @base_language = base_language
  end

  def valid?
    @is_valid
  end

  def create
    FormSection.new
  end

  def unique_id
    "unique_id"
  end
end

describe FormSectionController, :type => :controller do
  before do
    user = User.new(:user_name => 'manager_of_forms')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::FORMS[:manage]])])
    fake_login user
  end

  describe "get index" do
    it "populate the view with all the form sections in order ignoring enabled or disabled" do
      form = create :form
      form_section1 = create :form_section, :visible => false, :order => 1, :form => form
      form_section2 = create :form_section, :visible => true, :order => 2, :form => form

      get :index, :form_id => form.id

      expect(assigns[:form_sections]).to eq([form_section1, form_section2])
    end

    it "populate the view with only the specific forms fields" do
      form1 = create :form
      form2 = create :form
      form_section1 = create :form_section, :form => form1
      form_section2 = create :form_section, :form => form1
      form_section_that_should_not_be_returned = create :form_section, :form => form2

      get :index, :form_id => form1.id

      expect(assigns[:form_sections]).to eq([form_section1, form_section2])
    end

    it "respect order" do
      form1 = create :form
      form_section1 = create :form_section, order: 2, :form => form1
      form_section2 = create :form_section, order: 3, :form => form1
      form_section3 = create :form_section, order: 1, :form => form1

      get :index, :form_id => form1.id

      expect(assigns[:form_sections]).to eq([form_section3, form_section1, form_section2])
    end

    it "assigns form id" do
      form1 = create :form
      get :index, :form_id => form1.id
      expect(assigns[:form_id]).to eq(form1.id)
    end
  end

  describe "post create" do
    it "should new form_section with order" do
      existing_count = FormSection.count
      form = create :form
      form_section = {:name=>"name", :description=>"desc", :help_text=>"help text", :visible=>true}
      post :create, :form_section => form_section, :form_id => form.id
      expect(FormSection.count).to eq(existing_count + 1)
    end

    it "sets flash notice if form section is valid and redirect_to edit page with a flash message" do
      allow(FormSection).to receive(:new_with_order).and_return(MockFormSection.new)
      form = create :form
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section, :form_id => form.id
      expect(request.flash[:notice]).to eq("Form section successfully added")
      expect(response).to redirect_to(edit_form_section_path("unique_id"))
    end

    it "does not set flash notice if form section is valid and render new" do
      allow(FormSection).to receive(:new_with_order).and_return(MockFormSection.new(false))
      form = create :form
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section, :form_id => form.id
      expect(request.flash[:notice]).to be_nil
      expect(response).to render_template("new")
    end

    it "should assign view data if form section was not valid" do
      expected_form_section = MockFormSection.new(false)
      allow(FormSection).to receive(:new_with_order).and_return expected_form_section
      form = create :form
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section, :form_id => form.id
      expect(assigns[:form_section]).to eq(expected_form_section)
    end

    it "should assign the form to the new form section" do
      form = create :form
      form_section_params = {:name=>"name", :description=>"desc", :help_text=>"help text", :visible=>true}
      expect(FormSection).to receive(:new_with_order).with(include(:form => form))
      post :create, :form_section => form_section_params, :form_id => form.id
    end
  end

  describe "post save_order" do
    after { FormSection.all.each &:destroy }

    it "should save the order of the forms" do
      form = create :form
      form_one = FormSection.create(:unique_id => "first_form", :name => "first form", :order => 1, :form => form)
      form_two = FormSection.create(:unique_id => "second_form", :name => "second form", :order => 2, :form => form)
      form_three = FormSection.create(:unique_id => "third_form", :name => "third form", :order => 3, :form => form)
      post :save_order, :ids => [form_three.unique_id, form_one.unique_id, form_two.unique_id]
      expect(FormSection.get_by_unique_id(form_one.unique_id).order).to eq(2)
      expect(FormSection.get_by_unique_id(form_two.unique_id).order).to eq(3)
      expect(FormSection.get_by_unique_id(form_three.unique_id).order).to eq(1)
      expect(response).to redirect_to(form_form_sections_path(form))
    end
  end

  describe "post update" do
    it "should save update if valid" do
      form_section = FormSection.new
      params = {"some" => "params"}
      expect(FormSection).to receive(:get_by_unique_id).with("form_1").and_return(form_section)
      expect(form_section).to receive(:properties=).with(params)
      expect(form_section).to receive(:valid?).and_return(true)
      expect(form_section).to receive(:save!)
      post :update, :form_section => params, :id => "form_1"
      expect(response).to redirect_to(edit_form_section_path(form_section.unique_id))
    end

    it "should show errors if invalid" do
      form = create :form
      form_section = FormSection.new :form => form
      params = {"some" => "params"}
      expect(FormSection).to receive(:get_by_unique_id).with("form_1").and_return(form_section)
      expect(form_section).to receive(:properties=).with(params)
      expect(form_section).to receive(:valid?).and_return(false)
      post :update, :form_section => params, :id => "form_1"
      expect(response).not_to redirect_to(form_form_sections_path(form))
      expect(response).to render_template("edit")
    end
  end

  describe "post enable" do
    it "should toggle the given form_section to hide/show" do
      form_section1 = FormSection.create!({:name=>"name1", :description=>"desc", :visible=>"true", :unique_id=>"form_1"})
      form_section2 = FormSection.create!({:name=>"name2", :description=>"desc", :visible=>"false", :unique_id=>"form_2"})
      post :toggle, :id => "form_1"
      expect(FormSection.get_by_unique_id(form_section1.unique_id).visible).to be false
      post :toggle, :id => "form_2"
      expect(FormSection.get_by_unique_id(form_section2.unique_id).visible).to be true
    end
  end

  describe ".new" do
    it "should set form and form_section objects" do
      form = create :form
      form_section = build :form_section
      expect(FormSection).to receive(:new).and_return(form_section)

      get :new, :form_id => form.id

      expect(assigns[:form]).to eq(form)
      expect(assigns[:form_section]).to eq(form_section)
    end
  end

  describe ".edit" do
    it "should set form and form_section objects" do
      form = build :form
      form_section = build :form_section, :form => form
      expect(FormSection).to receive(:get_by_unique_id).with("foo").and_return(form_section)

      get :edit, :id => "foo"

      expect(assigns[:form]).to eq(form)
      expect(assigns[:form_section]).to eq(form_section)
    end
  end

end
