require 'spec_helper'

describe HighlightFieldsController, :type => :controller do

  describe "index" do
    it "should have no highlight fields" do
      allow(FormSection).to receive(:highlighted_fields).and_return([])
      user = User.new(:user_name => 'manager_of_forms')
      allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::SYSTEM[:highlight_fields]])])
      fake_login user
      get :index
      expect(assigns[:highlighted_fields]).to be_empty
    end

    it "should have forms assigned" do
      allow(FormSection).to receive(:enabled_by_order).and_return([FormSection.new(:name => "Form1"), FormSection.new(:name => "Form2")])
      fake_admin_login
      get :index
      expect(assigns[:form_sections].size).to eq(2)
    end

    it "should have highlighted fields assigned" do
      field1 = Field.new(:name => "field1", :display_name => "field1_display" , :highlight_information => { :order => "1", :highlighted => true })
      field2 = Field.new(:name => "field2", :display_name => "field2_display" , :highlight_information => { :order => "2", :highlighted => true })
      field3 = Field.new(:name => "field3", :display_name => "field3_display" , :highlight_information => { :order => "3", :highlighted => true })
      form1 = FormSection.new(:name => "Form1", :unique_id => "form1", :fields => [field1])
      form2 = FormSection.new(:name => "Form2", :unique_id => "form2", :fields => [field2])
      form3 = FormSection.new(:name => "Form3", :unique_id => "form3", :fields => [field3])
      allow(FormSection).to receive(:all).and_return([form1, form2, form3])
      fake_admin_login
      get :index
      expect(assigns[:highlighted_fields].size).to eq(3)
      expect(assigns[:highlighted_fields]).to eq([  { :field_name => "field1", :display_name => "field1_display" , :order => "1", :form_name => "Form1", :form_id => "form1" },
                                                { :field_name => "field2", :display_name => "field2_display" , :order => "2", :form_name => "Form2", :form_id => "form2" },
                                                { :field_name => "field3", :display_name => "field3_display" , :order => "3", :form_name => "Form3", :form_id => "form3" } ])
    end

  end

  describe "create" do
    it "should update field as highlighted" do
      field1 = Field.new(:name => "field1", :display_name => "field1_display" , :highlight_information => { :order => "1", :highlighted => true })
      field2 = Field.new(:name => "field2", :display_name => "field2_display" , :highlight_information => { :order => "2", :highlighted => true })
      field3 = Field.new(:name => "field3", :display_name => "field3_display")
      form = FormSection.new(:name => "Form1", :unique_id => "form1", :fields => [field1, field2, field3])
      allow(FormSection).to receive(:get_by_unique_id).and_return(form)
      expect(form).to receive(:update_field_as_highlighted).with("field3")
      fake_admin_login
      post :create, :form_id => "form1", :field_name => "field3"
    end
  end

  describe "remove" do
    it  "should unhighlight a field"  do
      field1 = Field.new(:name => "newfield1", :display_name => "new_field1_display" , :highlight_information => { :order => "1", :highlighted => true })
      form = FormSection.new(:name => "another form", :unique_id => "unique_form1", :fields => [field1])
      allow(FormSection).to receive(:get_by_unique_id).and_return(form)
      expect(form).to receive(:remove_field_as_highlighted).with("newfield1")
      fake_admin_login
      post :remove, :form_id => "form1", :field_name => "newfield1"
    end
  end
end
