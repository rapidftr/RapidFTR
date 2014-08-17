# -*- coding: utf-8 -*-
require 'spec_helper'

describe FieldsController, :type => :controller do
  before :each do
    user = User.new(:user_name => 'manager_of_forms')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::FORMS[:manage]])])
    fake_login user
  end

  describe "post create" do
    before :each do
      @field = Field.new :name => "my_new_field", :type => "TEXT", :display_name => "My New Field"
      @form_section = FormSection.new :name => "Form section 1", :unique_id => 'form_section_1'
      allow(FormSection).to receive(:get_by_unique_id).with(@form_section.unique_id).and_return(@form_section)
    end

    it "should add the new field to the formsection" do
      expect(FormSection).to receive(:add_field_to_formsection).with(@form_section, @field)
      post :create, :form_section_id => @form_section.unique_id, :field => JSON.parse(@field.to_json)
    end

    it "should redirect back to the fields page" do
      allow(FormSection).to receive(:add_field_to_formsection)
      post :create, :form_section_id => @form_section.unique_id, :field => JSON.parse(@field.to_json)
      expect(response).to redirect_to(edit_form_section_path(@form_section.unique_id))
    end

    it "should render edit form section page if field has errors" do
      allow(FormSection).to receive(:add_field_to_formsection)
      expect(Field).to receive(:new).and_return(@field)
      expect(@field).to receive(:errors).and_return(["errors"])
      post :create, :form_section_id => @form_section.unique_id, :field => JSON.parse(@field.to_json)
      expect(assigns[:show_add_field]).to eq(:show_add_field => true)
      expect(response).to be_success
      expect(response).to render_template("form_section/edit")
    end

    it "should show a flash message" do
      allow(FormSection).to receive(:add_field_to_formsection)
      post :create, :form_section_id => @form_section.unique_id, :field => JSON.parse(@field.to_json)
      expect(request.flash[:notice]).to eq("Field successfully added")
    end

    it "should use the display name to form the field name if no field name is supplied" do
      expect(FormSection).to receive(:add_field_to_formsection).with(anything, hash_including("display_name_#{I18n.locale}" => "My brilliant new field"))
      post :create, :form_section_id => @form_section.unique_id, :field => {:display_name => "My brilliant new field"}
    end

  end

  describe "edit" do
    it "should render form_section/edit template" do
      @form_section = FormSection.new
      field = double('field', :name => 'field1')
      allow(@form_section).to receive(:fields).and_return([field])
      allow(FormSection).to receive(:get_by_unique_id).with('unique_id').and_return(@form_section)
      get :edit, :form_section_id => "unique_id", :id => 'field1'
      expect(assigns[:body_class]).to eq("forms-page")
      expect(assigns[:field]).to eq(field)
      expect(assigns[:show_add_field]).to eq(:show_add_field => true)
      expect(response).to render_template('form_section/edit')
    end
  end

  describe "post move_up and move_down" do
    before :each do
      @form_section_id = "fred"
      @field_name = "barney"
      @form_section = FormSection.new
      allow(FormSection).to receive(:get_by_unique_id).with(@form_section_id).and_return(@form_section)
    end

    it "should save the given field in the same order as given" do
      expect(@form_section).to receive(:order_fields).with(%w(field_one field_two))
      post :save_order, :form_section_id => @form_section_id, :ids => %w(field_one field_two)
      expect(response).to redirect_to(edit_form_section_path(@form_section_id))
    end

  end

  describe "post toggle_fields" do

    before :each do
      @form_section_id = "fred"
      @form_section = FormSection.new
      allow(FormSection).to receive(:get_by_unique_id).with(@form_section_id).and_return(@form_section)
    end

    it "should toggle the given field" do
      fields = [double(:field, :name => 'bla', :visible => true)]

      expect(@form_section).to receive(:fields).and_return(fields)
      expect(fields.first).to receive(:visible=).with(false)
      expect(@form_section).to receive(:save)

      post :toggle_fields, :form_section_id => @form_section_id, :id => 'bla'
      expect(response.body).to eq("OK")
    end

  end

  describe "post update" do
    before { FormSection.all.each(&:destroy) }

    it "should update all attributes on field at once and render edit form sections page" do
      field_to_change = Field.new(:name => "country_of_origin", :display_name => "Origin Country", :visible => true,
        :help_text => "old help text")
      some_form = FormSection.create!(:name => "Some Form", :unique_id => "some_form", :fields => [field_to_change])

      put :update, :id => "country_of_origin", :form_section_id => some_form.unique_id,
        :field => {:display_name => "What Country Are You From", :visible => false, :help_text => "new help text"}

      updated_field = FormSection.get(some_form.id).fields.first
      expect(updated_field.display_name).to eq("What Country Are You From")
      expect(updated_field.visible).to eq(false)
      expect(updated_field.help_text).to eq("new help text")
      expect(response).to render_template("form_section/edit")
    end

    it "should display errors if field could not be saved" do
      field_with_error = double("field", :name => "field", :attributes= => [], :errors => ["error"])
      allow(FormSection).to receive(:get_by_unique_id).and_return(double("form_section", :fields => [field_with_error], :save => false, :form => build(:form)))

      put :update, :id => "field", :form_section_id => "unique_id",
          :field => {:display_name => "What Country Are You From", :visible => false, :help_text => "new help text"}

      expect(assigns[:show_add_field]).to eq(:show_add_field => true)
      expect(response).to render_template("form_section/edit")
    end

    it "should move the field to the given form_section" do
      mothers_name_field = Field.new(:name => "mothers_name", :visible => true, :display_name => "Mother's Name")
      another_field = Field.new(:name => "childs_name", :visible => true, :display_name => "Child's Name")
      family_details_form = FormSection.create!(:name => "Family Details", :unique_id => "family_details", :fields => [mothers_name_field])
      mother_details_form = FormSection.create!(:name => "Mother Details", :unique_id => "mother_details", :fields => [another_field])

      put :change_form, :id => mothers_name_field.name, :form_section_id => family_details_form.unique_id, :destination_form_id => mother_details_form.unique_id

      expect(FormSection.get(family_details_form.id).fields.find { |field| field.name == "mothers_name" }).to be_nil
      updated_field = FormSection.get(mother_details_form.id).fields.find { |field| field.name == "mothers_name" }
      expect(request.flash[:notice]).to eq("Mother's Name moved from Family Details to Mother Details")
      expect(response).to redirect_to(edit_form_section_path(family_details_form.unique_id))
    end

  end
end
