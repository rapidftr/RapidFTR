require 'spec_helper'

describe HighlightFieldsController, :type => :controller do

  describe "index" do
    it "should have forms assigned" do
      enquiry_form = create :form, name: Enquiry::FORM_NAME
      children_form = create :form, name: Child::FORM_NAME
      fake_admin_login
      get :index
      expect(assigns[:forms]).to contain_exactly(enquiry_form, children_form)
    end
  end

  describe "show" do
    it "should assign correct form" do
      children_form = create :form, name: Child::FORM_NAME
      enquiry_form = create :form, name: Enquiry::FORM_NAME
      fake_admin_login

      get :show, {id: enquiry_form.id}

      expect(assigns[:form]).to eq(enquiry_form)
    end

    it "should assign correct form sections" do
      children_form = create :form, name: Child::FORM_NAME
      create :form_section, form: children_form
      enquiry_form = create :form, name: Enquiry::FORM_NAME
      enquiry_section = create :form_section, form: enquiry_form
      fake_admin_login

      get :show, {id: enquiry_form.id}

      expect(assigns[:form_sections]).to contain_exactly(enquiry_section)
    end

    it "should assign correct highlighted fields" do
      children_form = create :form, name: Child::FORM_NAME
      create :form_section, form: children_form, fields: [build(:field, highlighted: true)]
      enquiry_form = create :form, name: Enquiry::FORM_NAME
      field = build :field, highlighted: true
      enquiry_section = create :form_section, form: enquiry_form, fields: [field]
      fake_admin_login

      get :show, {id: enquiry_form.id}

      highlighted_fields = assigns[:highlighted_fields]
      expect(highlighted_fields.size).to be(1)
      expect(highlighted_fields.first).to include(:field_name => field.name)
      expect(highlighted_fields.first).to include(:form_name => enquiry_section.name)
    end

    it "should return empty array when no highlighted fields exist" do
      children_form = create :form, name: Child::FORM_NAME
      fake_admin_login
      get :show, :id => children_form.id
      expect(assigns[:highlighted_fields]).to be_empty
    end

    it "should have highlighted fields assigned" do
      field1 = Field.new(:name => "field1", :display_name => "field1_display", :highlight_information => { :order => "1", :highlighted => true })
      field2 = Field.new(:name => "field2", :display_name => "field2_display", :highlight_information => { :order => "2", :highlighted => true })
      field3 = Field.new(:name => "field3", :display_name => "field3_display", :highlight_information => { :order => "3", :highlighted => true })
      section1 = FormSection.new(:name => "Section1", :unique_id => "section1", :fields => [field1])
      section2 = FormSection.new(:name => "Section2", :unique_id => "section2", :fields => [field2])
      section3 = FormSection.new(:name => "Section3", :unique_id => "section3", :fields => [field3])
      form = double("Form")
      allow(Form).to receive(:find).and_return(form)
      allow(form).to receive(:sections)
      allow(form).to receive(:sorted_highlighted_fields).and_return([field1, field2, field3])
      fake_admin_login
      get :show, :id => 0
      expect(assigns[:highlighted_fields].size).to eq(3)
      expect(assigns[:highlighted_fields]).to eq([{ :field_name => "field1", :display_name => "field1_display", :order => "1", :form_name => "Section1", :form_id => "section1" },
                                                  { :field_name => "field2", :display_name => "field2_display", :order => "2", :form_name => "Section2", :form_id => "section2" },
                                                  { :field_name => "field3", :display_name => "field3_display", :order => "3", :form_name => "Section3", :form_id => "section3" }])
    end

  end

  describe "create" do
    it "should update field as highlighted" do
      field1 = Field.new(:name => "field1", :display_name => "field1_display", :highlight_information => { :order => "1", :highlighted => true })
      field2 = Field.new(:name => "field2", :display_name => "field2_display", :highlight_information => { :order => "2", :highlighted => true })
      field3 = Field.new(:name => "field3", :display_name => "field3_display")
      form_section = FormSection.new(:name => "Form1", :unique_id => "form1", :fields => [field1, field2, field3])
      form = double("Form", id: :id)
      allow(form_section).to receive(:form).and_return(form)
      allow(FormSection).to receive(:get_by_unique_id).and_return(form_section)
      expect(form_section).to receive(:update_field_as_highlighted).with("field3")
      fake_admin_login
      post :create, :form_id => "form1", :field_name => "field3"
    end

    it "should redirect to highlight field page for form" do
      field = Field.new(:name => "field", :display_name => "field_display")
      form_section = FormSection.new(:name => "FormSection", :unique_id => "form_section", :fields => [field])
      allow(FormSection).to receive(:get_by_unique_id).and_return(form_section)
      expect(form_section).to receive(:update_field_as_highlighted).with("field")
      form = double("Form", id: :id)
      expect(form_section).to receive(:form).and_return(form)
      fake_admin_login
      post :create, :form_id => "form_section", :field_name => "field"
      expect(response).to redirect_to(highlight_field_url(form))
    end
  end

  describe "remove" do
    it  "should unhighlight a field"  do
      field1 = Field.new(:name => "newfield1", :display_name => "new_field1_display", :highlight_information => { :order => "1", :highlighted => true })
      form_section = FormSection.new(:name => "another form section", :unique_id => "unique_form_section1", :fields => [field1])
      form = double("Form", id: :id)
      allow(FormSection).to receive(:get_by_unique_id).and_return(form_section)
      allow(form_section).to receive(:form).and_return(form)
      expect(form_section).to receive(:remove_field_as_highlighted).with("newfield1")
      fake_admin_login
      post :remove, :form_id => "unique_form_section1", :field_name => "newfield1"

      expect(response).to redirect_to(highlight_field_url(form))
    end
  end
end
