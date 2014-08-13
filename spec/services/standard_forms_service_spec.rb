require 'spec_helper'

describe StandardFormsService do
  describe "#persist" do
    before :each do
      reset_couchdb!
    end

    describe "saving forms" do
      it "should persist enquiry form" do
        attributes = { "forms" => {
          "children" => { "user_selected" => "0", "id" => "children"},
          "enquiries" => { "user_selected" => "1", "id" => "enquiries"} } }
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 1
        expect(Form.all.first.name).to eq Enquiry::FORM_NAME
      end

      it "should persist child form" do
        attributes = { "forms" => {
          "children" => { "user_selected" => "1", "id" => "children"},
          "enquiries" => { "user_selected" => "0", "id" => "enquiries"} } }
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 1
        expect(Form.all.first.name).to eq Child::FORM_NAME
      end

      it "should save both forms "do
        attributes = { "forms" => {
          "children" => { "user_selected" => "1", "id" => "children"},
          "enquiries" => { "user_selected" => "1", "id" => "enquiries"} } }
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 2
        expect(Form.all.collect(&:name)).to include(Child::FORM_NAME, Enquiry::FORM_NAME)
      end

      it "should not add already existing forms" do
        create :form, name: Child::FORM_NAME
        attributes = { "forms" => {
          "children" => { "user_selected" => "0", "id" => "children",
                          "sections" => { "basic_identity" => { "user_selected" => "1", "id" => "basic_identity" } } } } }
        expect {StandardFormsService.persist(attributes)} .to_not change(Form, :count).from(1)
      end
    end

    describe "saving form sections" do
      it "should persist new form with new form sections" do
        attributes = { "forms" => {
          "children" => { "user_selected" => "1", "id" => "children",
                          "sections" => {
            "basic_identity" => {
              "user_selected" => "1",
              "id" => "basic_identity" }
          } } } }

          StandardFormsService.persist(attributes)

          expect(Form.count).to eq 1
          expect(FormSection.count).to eq 1
          expect(FormSection.all.first.unique_id).to eq("basic_identity")
          expect(FormSection.all.first.name).to eq("Basic Identity")
      end

      it "should persist new enquiry form with new enquiry criteria form sections" do
        attributes =  {"forms" => {"enquiries"=>
                                    {"user_selected"=>"1",
                                     "id"=>"enquiries",
                                     "sections"=>
                                       {"enquiry_criteria"=>
                                         {"user_selected"=>"1",
                                          "id"=>"enquiry_criteria",
                                          "fields"=>{"enquirer_name"=>{"user_selected"=>"1", "id"=>"enquirer_name"}, "criteria"=>{"user_selected"=>"1", "id"=>"criteria"}}}}}}}

          StandardFormsService.persist(attributes)

          expect(Form.count).to eq 1
          expect(Form.first.sections.length).to eq 1
          expect(FormSection.count).to eq 1
          expect(FormSection.all.first.unique_id).to eq("enquiry_criteria")
          expect(FormSection.all.first.form).to_not be_nil
          expect(FormSection.all.first.name).to eq("Enquiry Criteria")
      end

      it "should persist new form sections on existing forms with no form sections" do
        create :form, name: Child::FORM_NAME
        attributes = { "forms" => {
          "children" => { "user_selected" => "0", "id" => "children",
                          "sections" => {
            "basic_identity" => {
              "user_selected" => "1",
              "id" => "basic_identity" }
          } } } }

        expect {StandardFormsService.persist(attributes)} .to_not change(Form, :count).from(1)
        expect(FormSection.count).to eq 1
        expect(FormSection.all.first.name).to eq("Basic Identity")
        expect(FormSection.all.first.unique_id).to eq("basic_identity")
      end

      it "should persist new form sections on existing forms with form sections" do
        form = create :form, name: Child::FORM_NAME
        create :form_section, form: form, unique_id: "basic_identity", name: "Basic Identity"

        attributes = {
          "forms" => {
            "children" => {
              "user_selected" => "0",
              "id" => "children",
              "sections" => {
                "photos_and_audio" => {
                  "user_selected" => "1",
                  "id" => "photos_and_audio"
                }
              }
            }
          }
        }

        expect {StandardFormsService.persist(attributes)} .to_not change(Form, :count).from(1)
        expect(FormSection.count).to eq 2
        expect(FormSection.by_unique_id.key("photos_and_audio").first).to_not be_nil
      end
    end

    describe "saving fields" do
      it "should persist new form with new form sections with new fields" do
        attributes = { "forms" => {
          "children" => {
            "user_selected" => "1",
            "id" => "children",
            "sections" => {
              "basic_identity" => {
                "user_selected" => "1",
                "id" => "basic_identity",
                "fields" => {
                  "name" => {
                    "user_selected" => "1",
                    "id" => "name"
                } } } } } } }

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        section = FormSection.first
        expect(section.unique_id).to eq("basic_identity")
        expect(section.name).to eq("Basic Identity")
        expect(section.fields.length).to eq 1
        expect(section.fields.first.name).to eq("name")
      end

      it "should persist existing form with new form sections with new fields" do
        create :form, name: Child::FORM_NAME
        attributes = { "forms" => {
          "children" => {
            "user_selected" => "0",
            "id" => "children",
            "sections" => {
              "basic_identity" => {
                "user_selected" => "1",
                "id" => "basic_identity",
                "fields" => {
                  "name" => {
                    "user_selected" => "1",
                    "id" => "name"
                } } } } } } }

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        section = FormSection.first
        expect(section.unique_id).to eq("basic_identity")
        expect(section.name).to eq("Basic Identity")
        expect(section.fields.length).to eq 1
        expect(section.fields.first.name).to eq("name")
      end

      it "should persist existing form with existing form sections with new fields" do
        form = create :form, name: Child::FORM_NAME
        create :form_section, name: "Basic Identity", unique_id: "basic_identity", form: form, fields: []
        attributes = { "forms" => {
          "children" => {
            "user_selected" => "0",
            "id" => "children",
            "sections" => {
              "basic_identity" => {
                "user_selected" => "0",
                "id" => "basic_identity",
                "fields" => {
                  "name" => {
                    "user_selected" => "1",
                    "id" => "name"
                  } } } } } } }

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        section = FormSection.first
        expect(section.unique_id).to eq("basic_identity")
        expect(section.name).to eq("Basic Identity")
        expect(section.fields.length).to eq 1
        expect(section.fields.first.name).to eq("name")
      end

      it "should persist existing form with existing form sections with new fields" do
        form = create :form, name: Child::FORM_NAME
        create :form_section, name: "Basic Identity", unique_id: "basic_identity", form: form
        attributes = { "forms" => {
          "children" => {
            "user_selected" => "0",
            "id" => "children",
            "sections" => {
              "basic_identity" => {
                "user_selected" => "0",
                "id" => "basic_identity",
                "fields" => {
                  "name" => {
                    "user_selected" => "1",
                    "id" => "name"
                  } } } } } } }

        StandardFormsService.persist(attributes)

        section = FormSection.first
        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        expect(section.unique_id).to eq("basic_identity")
        expect(section.name).to eq("Basic Identity")
        expect(section.fields.length).to eq 2
        expect(section.fields.last.name).to eq("name")
      end

      it "should not persist new fields that match existing fields" do
        form = create :form, name: Child::FORM_NAME
        field = build :field, name: "name"
        create :form_section,
          name: "Basic Identity",
          unique_id: "basic_identity",
          form: form,
          fields: [field]
        attributes = { "forms" => {
          "children" => {
            "user_selected" => "0",
            "id" => "children",
            "sections" => {
              "basic_identity" => {
                "user_selected" => "0",
                "id" => "basic_identity",
                "fields" => {
                  "name" => {
                    "user_selected" => "1",
                    "id" => "name"
                  } } } } } } }

        StandardFormsService.persist(attributes)
        section = FormSection.first
        expect(section.fields.length).to eq 1
        expect(section.fields.last.name).to eq("name")
      end
end
  end
end



  # No form in DB, adding it with sections
  #
  #
  # Form in DB
  # # Section not in DB, not selected by user
  # # Section not in DB, selected by user
  # # Section already exists, adding fields
