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
end
