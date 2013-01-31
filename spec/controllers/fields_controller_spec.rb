# -*- coding: utf-8 -*-
require 'spec_helper'

describe FieldsController do
  before :each do
    user = User.new(:user_name => 'manager_of_forms')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::FORMS[:manage]])])
    fake_login user
  end

  describe "post create" do
    before :each do
      @field = Field.new :name => "my_new_field", :type=>"TEXT", :display_name => "My New Field"
      SuggestedField.stub(:mark_as_used)
      @form_section = FormSection.new :name => "Form section 1", :unique_id=>'form_section_1'
      FormSection.stub!(:get_by_unique_id).with(@form_section.unique_id).and_return(@form_section)
    end

    it "should add the new field to the formsection" do
      FormSection.should_receive(:add_field_to_formsection).with(@form_section, @field)
      post :create, :form_section_id =>@form_section.unique_id, :field => @field
    end

    it "should redirect back to the fields page" do
      FormSection.stub(:add_field_to_formsection)
      post :create, :form_section_id => @form_section.unique_id, :field => @field
      response.should redirect_to(edit_form_section_path(@form_section.unique_id))
    end

    it "should render edit form section page if field has errors" do
      FormSection.stub(:add_field_to_formsection)
      Field.should_receive(:new).and_return(@field)
      @field.should_receive(:errors).and_return(["errors"])
      post :create, :form_section_id => @form_section.unique_id, :field => @field
      assigns[:show_add_field].should == {"show_add_field" => true}
      response.should be_success
      response.should render_template("form_section/edit")
    end

    it "should show a flash message" do
      FormSection.stub(:add_field_to_formsection)
      post :create, :form_section_id => @form_section.unique_id, :field => @field
      request.flash[:notice].should == "Field successfully added"
    end

    it "should mark suggested field as used if one is supplied" do
      FormSection.stub(:add_field_to_formsection)
      suggested_field = "this_is_my_field"
      SuggestedField.should_receive(:mark_as_used).with(suggested_field)
      post :create, :form_section_id => @form_section.unique_id, :from_suggested_field => suggested_field, :field => @field
    end

    it "should not mark suggested field as used if there is not one supplied" do
      FormSection.stub(:add_field_to_formsection)
      SuggestedField.should_not_receive(:mark_as_used)
      post :create, :form_section_id => @form_section.unique_id, :field => @field
    end

    it "should use the display name to form the field name if no field name is supplied" do
      FormSection.should_receive(:add_field_to_formsection).with(anything(), hash_including("display_name_#{I18n.locale}" => "My brilliant new field"))
      post :create, :form_section_id => @form_section.unique_id, :field => {:display_name => "My brilliant new field"}
    end

  end

  describe "edit" do
    it "should render form_section/edit template" do
      @form_section = FormSection.new
      field = mock('field', :name => 'field1')
      @form_section.stub!(:fields).and_return([field])
      FormSection.stub!(:get_by_unique_id).with('unique_id').and_return(@form_section)
      get :edit, :form_section_id => "unique_id", :id => 'field1'
      assigns[:body_class].should == "forms-page"
      assigns[:field].should == field
      assigns[:show_add_field].should == {"show_add_field" => true}
      response.should render_template('form_section/edit')
    end
  end

  describe "post move_up and move_down" do
    before :each do
      @form_section_id = "fred"
      @field_name = "barney"
      @form_section = FormSection.new
      FormSection.stub!(:get_by_unique_id).with(@form_section_id).and_return(@form_section)
    end

    it "should save the given field in the same order as given" do
      @form_section.should_receive(:order_fields).with(["field_one", "field_two"])
      post :save_order, :form_section_id => @form_section_id, :ids => ["field_one", "field_two"]
      response.should redirect_to(edit_form_section_path(@form_section_id))
    end

  end

  describe "post toggle_fields" do

    before :each do
      @form_section_id = "fred"
      @form_section = FormSection.new
      FormSection.stub!(:get_by_unique_id).with(@form_section_id).and_return(@form_section)
    end

    it "should toggle the given field" do
      fields = [mock(:field, :name => 'bla', :visible => true)]

      @form_section.should_receive(:fields).and_return(fields)
      fields.first.should_receive(:visible=).with(false)
      @form_section.should_receive(:save)

      post :toggle_fields, :form_section_id => @form_section_id, :id => 'bla'
      response.should render_template :text => "OK"
    end

  end

  describe "post update" do
    before { FormSection.all.each &:destroy }

    it "should update all attributes on field at once and render edit form sections page" do
      field_to_change = Field.new(:name => "country_of_origin", :display_name => "Origin Country", :visible => true,
        :help_text => "old help text")
      some_form = FormSection.create!(:name => "Some Form", :unique_id => "some_form", :fields => [field_to_change])

      put :update, :id => "country_of_origin", :form_section_id => some_form.unique_id,
        :field => {:display_name => "What Country Are You From", :visible => false, :help_text => "new help text"}

      updated_field = FormSection.get(some_form.id).fields.first
      updated_field.display_name.should == "What Country Are You From"
      updated_field.visible.should == false
      updated_field.help_text.should == "new help text"
      response.should render_template("form_section/edit")
    end

    it "should display errors if field could not be saved" do
      field_with_error = mock("field", :name => "field", :attributes= => [], :errors => ["error"])
      FormSection.stub(:get_by_unique_id).and_return(mock("form_section", :fields => [field_with_error], :save => false))

      put :update, :id => "field", :form_section_id => "unique_id",
          :field => {:display_name => "What Country Are You From", :visible => false, :help_text => "new help text"}

      assigns[:show_add_field].should == {"show_add_field" => true}
      response.should render_template("form_section/edit")
    end

    it "should move the field to the given form_section" do
      mothers_name_field = Field.new(:name => "mothers_name", :visible => true, :display_name => "Mother's Name")
      another_field = Field.new(:name => "childs_name", :visible => true, :display_name => "Child's Name")
      family_details_form = FormSection.create!(:name => "Family Details", :unique_id => "family_details", :fields => [mothers_name_field])
      mother_details_form = FormSection.create!(:name => "Mother Details", :unique_id => "mother_details", :fields => [another_field])

      put :change_form, :id => mothers_name_field.name, :form_section_id => family_details_form.unique_id, :destination_form_id => mother_details_form.unique_id

      FormSection.get(family_details_form.id).fields.find {|field| field.name == "mothers_name"}.should be_nil
      updated_field = FormSection.get(mother_details_form.id).fields.find {|field| field.name == "mothers_name"}
      request.flash[:notice].should == "Mother's Name moved from Family Details to Mother Details"
      response.should redirect_to(edit_form_section_path(family_details_form.unique_id))
    end

  end
end
