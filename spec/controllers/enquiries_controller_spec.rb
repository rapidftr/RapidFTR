require 'spec_helper'

describe EnquiriesController, :type => :controller do
  describe '#index', :solr => true do
    before :each do
      Sunspot.remove_all!
    end

    shared_examples_for 'viewing enquiries by user with access to all data' do
      describe 'when the signed in user has access all data' do
        before do
          role = create :role, :permissions => [Permission::ENQUIRIES[:create]]
          user = create :user, :role_ids => [role.id]
          @session = setup_session user
          @params ||= {}
          @params.merge!(:filter => @filter) if @filter
          @expected_enquiry ||= [create(:enquiry, :created_by => @session.user_name)]
        end

        it 'should assign all enquiries as @enquiries' do
          get :index, @params
          expect(assigns[:enquiries]).to eq(@expected_enquiries)
        end
      end
    end

    shared_examples_for 'viewing enquiries as a field worker' do
      describe 'when the signed in user is a field worker' do
        before do
          @session ||= fake_field_worker_login
          @params ||= {}
          @params.merge!(:filter => @filter) if @filter
          @expected_enquiries ||= [create(:enquiry, :created_by => @session.user_name)]
        end

        it 'should assign the enquiries created by the user as @enquiries' do
          get :index, @params
          expect(assigns[:enquiries]).to eq(@expected_enquiries)
        end
      end
    end

    context 'viewing reunited enquiries' do
      context 'admin' do
        before do
          @field_worker = create :user
          create(:enquiry, :created_by => @field_worker.user_name)
          @expected_enquiries = [create(:enquiry, :created_by => @field_worker.user_name, :reunited => true)]
          @filter = 'reunited'
        end
        it_should_behave_like 'viewing enquiries by user with access to all data'
      end
      context 'field worker' do
        before do
          @session = fake_field_worker_login
          create(:enquiry, :created_by => @session.user_name)
          @expected_enquiries = [create(:enquiry, :created_by => @session.user_name, :reunited => true)]
          @filter = 'reunited'
        end
        it_should_behave_like 'viewing enquiries as a field worker'
      end
    end

    context 'viewing enquiries with matches' do
      context 'admin' do
        before do
          @field_worker = create :user
          create(:enquiry, :created_by => @field_worker.user_name)
          expected_enquiry = create(:enquiry, :created_by => @field_worker.user_name, :flag => true)
          PotentialMatch.create(:enquiry_id => expected_enquiry.id, :child_id => '1')
          expected_enquiry.reload
          expected_enquiry.save
          @expected_enquiries = [expected_enquiry]
          @filter = 'has_matches'
        end
        it_should_behave_like 'viewing enquiries by user with access to all data'
      end
      context 'field_worker' do
        before do
          @session = fake_field_worker_login
          create(:enquiry, :created_by => @session.user_name)
          expected_enquiry = create(:enquiry, :created_by => @session.user_name, :flag => true)
          PotentialMatch.create(:enquiry_id => expected_enquiry.id, :child_id => '1')
          expected_enquiry.reload
          expected_enquiry.save
          @expected_enquiries = [expected_enquiry]
          @filter = 'has_matches'
        end
        it_should_behave_like 'viewing enquiries as a field worker'
      end
    end

    context 'viewing enquiries with confirmed matches' do
      context 'admin' do
        before do
          @field_worker = create :user
          create(:enquiry, :created_by => @field_worker.user_name)
          unexpected_enquiry = create(:enquiry, :created_by => @field_worker.user_name, :flag => true)
          PotentialMatch.create(:enquiry_id => unexpected_enquiry.id, :child_id => '1')
          unexpected_enquiry.reload
          unexpected_enquiry.save
          expected_enquiry = create(:enquiry, :created_by => @field_worker.user_name, :flag => true)
          PotentialMatch.create(:enquiry_id => expected_enquiry.id, :child_id => '1', :status => PotentialMatch::CONFIRMED)
          expected_enquiry.reload
          expected_enquiry.save
          @expected_enquiries = [expected_enquiry]
          @filter = 'has_confirmed_match'
        end
        it_should_behave_like 'viewing enquiries by user with access to all data'
      end
      context 'field worker' do
        before { @options = {:startkey => %w(active fakefieldworker), :endkey => ['active', 'fakefieldworker', {}], :page => 1, :per_page => 20, :view_name => :by_all_view_with_created_by_created_at} }
        it_should_behave_like 'viewing enquiries as a field worker'
      end
    end
  end

  describe '#new' do

    before :each do
      reset_couchdb!
      @session = fake_field_worker_login
      allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
    end

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
      reset_couchdb!
      @session = fake_field_worker_login
      allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
    end

    before :each do
      field1 = build(:field, :name => 'enquirer_name')
      field2 = build(:field, :name => 'child_name')
      field3 = build(:photo_field, :name => 'photo')
      field4 = build(:audio_field, :name => 'audio')

      form = create(:form, :name => Enquiry::FORM_NAME)
      create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [field1, field2, field3, field4])
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

    describe 'photos and audio' do
      before :each do
        @photo_jeff  = Rack::Test::UploadedFile.new(Rails.root + 'features/resources/jeff.png', 'image/png')
        @photo_jorge = Rack::Test::UploadedFile.new(Rails.root + 'features/resources/jorge.jpg', 'image/jpg')
        @audio = Rack::Test::UploadedFile.new(Rails.root + 'features/resources/sample.mp3', 'audio/mp3')

        @enquiry = {
          'enquirer_name' => 'John Doe',
          'child_name' => 'Kasozi'
        }
      end

      it 'should save a photo along with the enquiry' do
        @enquiry['photo'] = {'0' => @photo_jeff}

        post :create, :enquiry => @enquiry

        enquiry = Enquiry.first
        expect(enquiry[:enquirer_name]).to eq @enquiry['enquirer_name']
        expect(enquiry[:child_name]).to eq @enquiry['child_name']
        expect(enquiry.photos.size).to eq 1
        expect(enquiry.photo_keys.size).to eq 1
      end

      it 'should save multiple photos along with the enquiry' do
        @enquiry['photo'] = {'0' => @photo_jeff, '1' => @photo_jorge}

        post :create, :enquiry => @enquiry

        enquiry = Enquiry.first
        expect(enquiry[:enquirer_name]).to eq @enquiry['enquirer_name']
        expect(enquiry[:child_name]).to eq @enquiry['child_name']
        expect(enquiry.photos.size).to eq 2
        expect(enquiry.photo_keys.size).to eq 2
      end

      it 'should save an audio attachment along with the enquiry' do
        @enquiry['audio'] = @audio

        post :create, :enquiry => @enquiry

        enquiry = Enquiry.first
        expect(enquiry[:enquirer_name]).to eq @enquiry['enquirer_name']
        expect(enquiry[:child_name]).to eq @enquiry['child_name']
        expect(enquiry.recorded_audio).not_to be_nil
      end

      it 'should save a single photo and audio file along with the enquiry' do
        @enquiry['photo'] = {'0' => @photo_jeff}
        @enquiry['audio'] = @audio

        post :create, :enquiry => @enquiry

        enquiry = Enquiry.first
        expect(enquiry[:enquirer_name]).to eq @enquiry['enquirer_name']
        expect(enquiry[:child_name]).to eq @enquiry['child_name']
        expect(enquiry.photos.size).to eq 1
        expect(enquiry.photo_keys.size).to eq 1
        expect(enquiry.recorded_audio).not_to be_nil
      end

      it 'should save multiple photos and an audio file along with the enquiry' do
        @enquiry['photo'] = {'0' => @photo_jeff, '1' => @photo_jorge}
        @enquiry['audio'] = @audio

        post :create, :enquiry => @enquiry

        enquiry = Enquiry.first
        expect(enquiry[:enquirer_name]).to eq @enquiry['enquirer_name']
        expect(enquiry[:child_name]).to eq @enquiry['child_name']
        expect(enquiry.photos.size).to eq 2
        expect(enquiry.photo_keys.size).to eq 2
        expect(enquiry.recorded_audio).not_to be_nil
      end
    end
  end

  describe '#show' do

    before :each do
      reset_couchdb!
      @session = fake_field_worker_login
      allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
    end

    before :each do
      field1 = build :field, :name => 'enquirer_name'
      field2 = build :field, :name => 'child_name'
      field3 = build :photo_field, :name => 'photo'
      form = create :form, :name => Enquiry::FORM_NAME
      @form_section = create :form_section, :name => 'enquiry_criteria', :form => form, :fields => [field1, field2, field3]
      @enquiry = create :enquiry, :created_by => @session.user_name, :photo => uploadable_photo
    end

    it 'should not show enquiry if user has no permission to view enquiry' do
      allow(@controller.current_ability).to receive(:can?).with(:read, Enquiry).and_return(false)

      get :show, :id => @enquiry.id

      expect(response.status).to eq(403)
    end

    it 'should show an enquiry if the user has permissions to view enquiry' do
      get :show, :id => @enquiry.id

      expect(assigns[:enquiry]).to eq @enquiry
      expect(assigns[:enquiry].primary_photo).to match_photo uploadable_photo
      expect(assigns[:form_sections]).to eq [@form_section]
      expect(response).to render_template('show')
    end
  end

  describe '#update enquiry', :solr => true do

    before :each do
      reset_couchdb!
      @session = fake_field_worker_login
      allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
    end

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
      photo_field = build(:photo_field, :name => 'photo')
      audio_field = build(:audio_field, :name => 'audio')
      @form_section = create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field, location_field, gender_field, photo_field, audio_field])
      @enquiry = create(:enquiry, :enquirer_name => 'John doe', :child_name => 'any child', :gender => 'male', :location => 'kampala', :photo => uploadable_photo, :audio => uploadable_audio_mp3)
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

      describe 'photos and audio' do
        it 'should not change the photo and audio after updating an enquiry' do
          new_enquiry_attributes = {:enquirer_name => 'Hello'}

          put :update, :id => @enquiry.id, :enquiry => new_enquiry_attributes

          enquiry = Enquiry.find @enquiry.id
          expect(enquiry.photos.size).to eq 1
          expect(enquiry.primary_photo).to match_photo uploadable_photo
          expect(enquiry.recorded_audio).not_to be_nil
        end
      end
    end
  end
end
