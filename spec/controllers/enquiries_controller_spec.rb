require 'spec_helper'

describe EnquiriesController, :type => :controller do

  before :each do
    reset_couchdb!
    @session = fake_field_worker_login
  end

  describe '#new' do
    it 'should render new form' do
      get :new
      expect(response).to render_template('new')
    end

    it 'should assign the form' do
      enquiry_form = create :form, :name => Enquiry::FORM_NAME
      create :form_section, :form => enquiry_form
      form_sections = FormSection.all_form_sections_for Enquiry::FORM_NAME

      get :new
      assigned_form_sections = assigns[:form_sections]

      expect(assigned_form_sections).to eq form_sections
      expect(assigned_form_sections.first.fields.length).to eq 1
    end
  end

  describe '#create' do

    before :each do
      field1 = build(:field, :name => 'enquirer_name')
      field2 = build(:field, :name => 'child_name')
      form = create(:form, :name => Enquiry::FORM_NAME)
      create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [field1, field2])
    end

    it 'should fail if user is not authorized to create enquiry' do
      allow(@controller.current_ability).to receive(:can?).with(:create, Enquiry).and_return(false)
      params = {
        :enquiry => {
          'enquirer_name' => 'John Doe',
          'child_name' => 'Kasozi'
        }
      }

      expect { post :create, params }.not_to change(Enquiry, :count)
      expect(response.status).to eq(403)
    end

    it 'should return to the new enquiry page' do
      params = {
        :enquiry => {}
      }

      post :create, params
      expect(response).to render_template :new
    end

    it 'should save a new enquiry in the database' do
      params = {
        :enquiry => {
          'enquirer_name' => 'John Doe',
          'child_name' => 'Kasozi'
        }
      }

      expect { post :create, params }.to change(Enquiry, :count).from(0).to(1)
      expect(Enquiry.first.enquirer_name).to eq 'John Doe'
      expect(Enquiry.first.criteria).to eq params[:enquiry]
    end

    it 'should add a created_by field to the enquiry' do
      params = {
        :enquiry => {
          'enquirer_name' => 'John Doe',
          'child_name' => 'Kasozi'
        }
      }

      post :create, params
      enquiry = Enquiry.first
      expect(enquiry[:created_by]).to eq 'fakefieldworker'
    end

    it 'should redirect to enquiry show page' do
      params = {
        :enquiry => {
          'enquirer_name' => 'John Doe',
          'child_name' => 'Kasozi'
        }
      }

      post :create, params

      enquiry = Enquiry.first
      expect(response).to redirect_to enquiry_path(enquiry)
    end
  end

  describe '#show' do

    before :each do
      field1 = build :field, :name => 'enquirer_name'
      field2 = build :field, :name => 'child_name'
      form = create :form, :name => Enquiry::FORM_NAME
      @form_section = create :form_section, :name => 'enquiry_criteria', :form => form, :fields => [field1, field2]
      @enquiry = create :enquiry, :created_by => @session.user_name
    end

    it 'should not show enquiry if user has no permission to view enquiry' do
      allow(@controller.current_ability).to receive(:can?).with(:read, Enquiry).and_return(false)

      get :show, :id => @enquiry.id

      expect(response.status).to eq(403)
    end

    it 'should show an enquiry if the user has permissions to view enquiry' do
      get :show, :id => @enquiry.id
      expect(assigns[:enquiry]).to eq @enquiry
      expect(assigns[:form_sections]).to eq [@form_section]
      expect(response).to render_template('show')
    end
  end

  describe '#update enquiry', :solr => true do
    before :each do
      Sunspot.setup(Child) do
        text :child_name
        text :location
        text :gender
      end
      @child = create(:child, :child_name => 'any child', :location => 'Kampala', :gender => 'male')
      form = create(:form, :name => Enquiry::FORM_NAME)
      enquirer_name_field = build(:text_field, :name => 'enquirer_name')
      child_name_field = build(:text_field, :name => 'child_name')
      gender_field = build(:text_field, :name => 'gender')
      location_field = build(:text_field, :name => 'location')
      @form_section = create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field, location_field, gender_field])
      @enquiry = create(:enquiry, :enquirer_name => 'John doe', :child_name => 'any child', :gender => 'male', :location => 'kampala')
      allow(controller.current_ability).to receive(:can?).with(:update, Enquiry).and_return(true)
    end

    describe '#edit' do

      it 'should render edit template' do
        get :edit, :id => @enquiry.id

        expect(response).to render_template :edit
      end

      it 'should load an enquiry' do
        get :edit, :id => @enquiry.id

        expect(assigns[:enquiry]).to eq @enquiry
      end

      it 'load form sections for the enquiry form' do
        get :edit, :id => @enquiry.id

        expect(assigns[:form_sections]).to eq [@form_section]
      end
    end

    describe '#update' do
      it 'should not change enquiry given empty params' do
        put :update, :id => @enquiry.id

        updated_enquiry = Enquiry.find @enquiry.id
        expect(updated_enquiry).to eq @enquiry
      end

      it 'should update the attributes of an enquiry' do
        new_enquiry_attributes = {:enquirer_name => 'David jones'}

        put :update, :id => @enquiry.id, :enquiry => new_enquiry_attributes

        updated_enquiry = Enquiry.get(@enquiry.id)
        expect(updated_enquiry[:enquirer_name]).to eq(new_enquiry_attributes[:enquirer_name])
      end

      it 'should redirect to show page after succcessful update' do
        new_enquiry_attributes = {:enquirer_name => 'David jones'}

        put :update, :id => @enquiry.id, :enquiry => new_enquiry_attributes

        expect(response).to redirect_to enquiry_path(@enquiry)
      end

      it 'should return to edit page after unsuccessful update' do
        enquiry = instance_double('Enquiry', :update_attributes => false)
        allow(Enquiry).to receive(:find).and_return(enquiry)
        new_enquiry_attributes = {:enquirer_name => 'Hello'}

        put :update, :id => @enquiry.id, :enquiry => new_enquiry_attributes

        expect(response).to render_template :edit
        expect(assigns[:enquiry]).to eq enquiry
        expect(assigns[:form_sections]).to eq [@form_section]
      end
    end
  end
end
