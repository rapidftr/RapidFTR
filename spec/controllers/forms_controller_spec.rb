require 'spec_helper'

describe FormsController, :type => :controller do
  before :each do
    reset_couchdb!
  end

  describe ".index" do
    it "should assign all Forms for use in the view" do
      enquiry_form = create :form, name: Enquiry::FORM_NAME
      children_form = create :form, name: Child::FORM_NAME
      fake_admin_login
      get :index
      expect(assigns[:form_sections]).to contain_exactly(enquiry_form, children_form)
    end
  end

  describe ".bulk_update" do
    before :each do
      fake_admin_login
    end
    describe "adding or updating forms" do
      it "should create enquiry form if included in the params" do
        params = {:enquiry_form_sections=> []}
        expect{post :bulk_update, params}.to change(Form, :count).from(0).to(1)
        expect(Form.first.name).to eq(Enquiry::FORM_NAME)
      end

      it "should not create a form if no params are provided" do
        params = {}
        expect{post :bulk_update, params}.to_not change(Form, :count)
      end

      it "should create child form if included in the params" do
        params = {:child_form_sections => []}
        expect{post :bulk_update, params}.to change(Form, :count).from(0).to(1)
        expect(Form.first.name).to eq(Child::FORM_NAME)
      end

      it "should create multiple forms" do
        params = {:enquiry_form_sections=> [], :child_form_sections => []}
        expect{post :bulk_update, params}.to change(Form, :count).from(0).to(2)
        expect(Form.all.collect(&:name)).to include(Child::FORM_NAME, Enquiry::FORM_NAME)
      end

      it "should not create a form that already exists" do
        create :form, name: Enquiry::FORM_NAME
        create :form, name: Child::FORM_NAME
        params = {:enquiry_form_sections=> [], :child_form_sections => []}
        expect{post :bulk_update, params}.to_not change(Form, :count).from(2)
      end
    end

    describe "adding or updating form sections" do
      it "should not create new form sections if none are included in params" do
        params = {:enquiry_form_sections => []}
        expect{post :bulk_update, params}.to_not change(FormSection, :count).from(0)
      end

      it "should create a new enquiry form section included in params" do
        params = {:enquiry_form_sections => ["enquiry_criteria"], :enquiry_criteria => []}
        expect{post :bulk_update, params}.to change(FormSection, :count).from(0).to(1)
        expect(FormSection.first.name).to eq("Enquiry Criteria")
      end

      it "should create a new child form section included in params" do
        params = {:child_form_sections => ["basic_identity"], :basic_identity => []}
        expect{post :bulk_update, params}.to change(FormSection, :count).from(0).to(1)
        expect(FormSection.first.name).to eq("Basic Identity")
      end

      it "should assign form sections to appropriate forms" do
        params = {
          :child_form_sections => ["basic_identity"],
          :basic_identity => [],
          :enquiry_form_sections => ["enquiry_criteria"],
          :enquiry_criteria => [],
        }

        expect{post :bulk_update, params}.to change(FormSection, :count).from(0).to(2)
        form_sections = FormSection.all.all
        child_form_section = form_sections.select {|fs| fs.form.name == Child::FORM_NAME}
        enquiry_form_section = form_sections.select {|fs| fs.form.name == Enquiry::FORM_NAME}

        expect(child_form_section.first.name).to eq("Basic Identity")
        expect(enquiry_form_section.first.name).to eq("Enquiry Criteria")
      end
    end

    describe "adding or updating fields" do
      it "should fill in fields on new form section" do
        params = {
          :child_form_sections => ["basic_identity"],
          :basic_identity => ["name", "gender"]
        }
        post :bulk_update, params
        expect(FormSection.first.fields.size).to be(2)
        expect(FormSection.first.fields.collect(&:name)).to include("name", "gender")
      end

      it "should add field on existing form section" do
        form = create :form, :name => Child::FORM_NAME
        create :form_section, :name => "Basic Identity", :form => form
        params = {
          :child_form_sections => ["basic_identity"],
          :basic_identity => ["name", "gender"]
        }
        expect{post :bulk_update, params}.not_to change(FormSection, :count).from(1)
        expect(FormSection.first.fields.size).to be(3)
        expect(FormSection.first.fields.collect(&:name)).to include("name", "gender", "name_1000000")
      end
    end
  end
end
