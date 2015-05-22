require 'spec_helper'

describe Api::EnquiriesController, :type => :controller do

  before :each do
    reset_couchdb!

    Enquiry.all.each { |enquiry| enquiry.destroy }
    fake_admin_login
    Sunspot.remove_all!

    form = create :form, :name => Enquiry::FORM_NAME

    create :form_section, :name => 'test_form', :fields => [
      build(:text_field, :name => 'name'),
      build(:text_field, :name => 'location'),
      build(:text_field, :name => 'nationality'),
      build(:text_field, :name => 'enquirer_name'),
      build(:numeric_field, :name => 'age'),
      build(:text_field, :name => 'gender')
    ], :form => form
    allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
  end

  describe '#authorizations' do
    it 'should fail to POST create when unauthorized' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      expect(@controller.current_ability).to receive(:can?).with(:create, Enquiry).and_return(false)
      post :create
      expect(response).to be_forbidden
    end

    it 'should fail to update when unauthorized' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      expect(@controller.current_ability).to receive(:can?).with(:update, Enquiry).and_return(false)
      test_id = '12345'
      put :update, :id => test_id, :enquiry => {:id => test_id, :enquirer_name => 'new name'}
      expect(response).to be_forbidden
    end
  end

  describe 'POST create' do

    it 'should trigger the match functionality every time a record is created' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      name = 'reporter'
      details = {'location' => 'Kampala'}
      criteria = {'name' => 'Magso'}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :criteria => criteria}, :format => :json
    end

    it 'should not trigger the match unless record is created' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      expect(Enquiry).not_to receive(:find_matching_children)

      post :create, :enquiry => {}

      expect(response.response_code).to eq(422)
    end

    it 'should create the enquiry record and return a success code' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      name = 'reporter'

      details = {'location' => 'Kampala'}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :name => 'name'}

      expect(Enquiry.all.total_rows).to eq(1)
      enquiry = Enquiry.all.first

      expect(enquiry.enquirer_name).to eq(name)
      expect(response.response_code).to eq(201)
    end

    it 'should return an enquiry json without internal fields' do
      enquiry = build :enquiry
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(Enquiry).to receive(:new_with_user_name).and_return(enquiry)
      allow(controller).to receive(:authorize!)
      expect(enquiry).to receive(:without_internal_fields).and_return(enquiry)
      post :create, :enquiry => {:enquirer_name => 'reporter',
                                 :reporter_details => {'location' => 'Kampala'},
                                 :name => 'name'}
    end

    it 'should not update record if it exists and return error' do
      enquiry = Enquiry.new(:enquirer_name => 'old name', :'location' => 'kampala', :name => 'name')
      enquiry.save!
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)

      post :create, :enquiry => {'id' => enquiry.id, :enquirer_name => 'new name', :name => 'name'}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq('old name')
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)['error']).to eq('Forbidden')
    end

    it 'should not overwrite creation information from mobile' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(RapidFTR::Clock).to receive(:current_formatted_time).and_return('2014-08-26 08:15:22 +0000')
      enquiry = {:enquirer_name => 'John Doe',
                 :created_by => 'Foo Bar',
                 :created_organisation => 'UNICEF',
                 :created_at => '2014-08-25 08:15:22 +0000'}

      post :create, :enquiry => enquiry

      saved_enquiry = Enquiry.first
      expect(saved_enquiry[:created_by]).to eq enquiry[:created_by]
      expect(saved_enquiry[:created_at]).to eq enquiry[:created_at]
      expect(saved_enquiry[:created_organisation]).to eq enquiry[:created_organisation]
      expect(saved_enquiry[:posted_at]).to eq '2014-08-26 08:15:22 +0000'
    end

    it 'should not duplicate histories from params' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      enquiry = {:enquirer_name => 'John Doe',
                 :histories => [{:changes => {:enquirer_name => {:from => '', :to => 'John Doe'}}}]
      }

      post :create, :enquiry => enquiry
      saved_enquiry = Enquiry.first
      expect(saved_enquiry['histories'].length).to eq 1
      expect(saved_enquiry['histories'].first['changes']).to eq('enquirer_name' => {'from' => '', 'to' => 'John Doe'})
    end
  end

  describe 'PUT update' do

    it 'should trigger the match functionality every time a record is created' do
      criteria = {'name' => 'old name'}
      enquiry = Enquiry.create(:enquirer_name => 'Machaba', :reporter_details => {'location' => 'kampala'}, :criteria => criteria)
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :criteria => criteria}, :format => :json

      expect(response.response_code).to eq(200)
    end

    it 'should not include internal fields in the returned json' do
      enquiry = create :enquiry
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      put :update, :id => enquiry.id, :enquiry => {:id => 'enquiry_id', :enquirer_name => 'new name', :criteria => 'criteria'}, :format => :json

      json_response = JSON.parse(response.body)
      expect(json_response['histories']).to be_nil
      expect(json_response['criteria']).to be_nil
    end

    it 'should not trigger the match unless record is created' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      enquiry = Enquiry.create(:enquirer_name => 'Machaba', :reporter_details => {'location' => 'kampala'})
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => ''}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should return an error if enquiry does not exist' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      id = '12345'
      allow(Enquiry).to receive(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :enquirer_name => 'new name'}

      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)['error']).to eq('Not found')
    end

    it 'should merge existing criteria when sending new values in criteria' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.new(:enquirer_name => 'old name', :location => 'kampala', :name => 'Batman')
      enquiry.save!

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :gender => 'Male'}

      expect(response.response_code).to eq(200)
      expect(Enquiry.get(enquiry.id)[:criteria]).to eq('name' => 'Batman', 'gender' => 'Male', 'enquirer_name' => 'new name', 'location' => 'kampala')
      expect(JSON.parse(response.body)['error']).to be_nil
    end

    it 'should update record if it exists and return the updated record' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.create(:enquirer_name => 'old name')
      put :update, :id => enquiry.id,
                   :enquiry => {:id => enquiry.id, :enquirer_name => 'new name'}

      enquiry = Enquiry.get(enquiry.id)

      expect(enquiry.enquirer_name).to eq('new name')
      expect(response.response_code).to eq(200)
      expect(enquiry[:criteria]).to eq('enquirer_name' => 'new name')
    end

    it 'should update record without passing the id in the enquiry params' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.create(:enquirer_name => 'old name', :reporter_details => {'location' => 'kampala'})

      put :update, :id => enquiry.id, :enquiry => {:enquirer_name => 'new name'}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq('new name')
      expect(response.response_code).to eq(200)
      expect(enquiry[:criteria]).to eq('enquirer_name' => 'new name')
    end

    it 'should merge updated fields and return the latest record' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.create(:enquirer_name => 'old name', :location => 'kampala', :name => 'child name')

      put :update, :id => enquiry.id, :enquiry => {:name => 'child new name'}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.criteria).to eq('name' => 'child new name', 'enquirer_name' => 'old name', 'location' => 'kampala')

      put :update, :id => enquiry.id, :enquiry => {:location => 'Kampala', :age => '100', :gender => 'female'}

      enquiry = Enquiry.get(enquiry.id)

      expect(enquiry.criteria).to eq('name' => 'child new name', 'gender' => 'female', 'enquirer_name' => 'old name', 'location' => 'Kampala', 'age' => '100')
      expect(enquiry['age']).to eq('100')
      expect(enquiry['location']).to eq('Kampala')
      expect(response.response_code).to eq(200)
    end

    
    it 'should update existing enquiry with potential matches', :solr => true do
      reset_couchdb!
      form = create :form, :name => Enquiry::FORM_NAME
      create :form_section, :fields => [
        build(:text_field, :name => 'child_name', :matchable => true),
        build(:text_field, :name => 'age', :matchable => true),
        build(:text_field, :name => 'location', :matchable => true),
        build(:text_field, :name => 'sex', :matchable => true)
      ], :form => form

      form = create :form, :name => Child::FORM_NAME
      create :form_section, :fields => [
        build(:text_field, :name => 'name'),
        build(:text_field, :name => 'gender')
      ], :form => form
      Child.reindex!

      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      child1 = Child.create('name' => 'Clayton aquiles', 'created_by' => 'fakeadmin', 'created_organisation' => 'stc')
      child2 = Child.create('name' => 'Steven aquiles', 'gender' => 'male', 'created_by' => 'fakeadmin', 'created_organisation' => 'stc')

      enquiry = Enquiry.create(:enquirer_name => 'Godwin', :sex => 'male', :age => '10', :location => 'Kampala')

      expect(Enquiry.get(enquiry.id).potential_matches.map(&:child)).to include(child2)

      put :update, :id => enquiry.id, :enquiry => {:child_name => 'aquiles', :age => '10', :location => 'Kampala'}
      expect(response.response_code).to eq(200)

      enquiry_after_update = Enquiry.get(enquiry.id)
      expect(enquiry_after_update.potential_matches.size).to eq(2)
      expect(enquiry_after_update.potential_matches.map(&:child)).to include(child1)
      expect(enquiry_after_update.potential_matches.map(&:child)).to include(child2)
      expect(enquiry_after_update['criteria']).to eq('child_name' => 'aquiles', 'age' => '10', 'location' => 'Kampala', 'sex' => 'male')
    end

    it 'should not duplicate or replace histories from params' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      Timecop.freeze Time.parse('2014-09-26 10:10:10 UTC') do
        enquiry_params = {:enquirer_name => 'John Doe',
                          :histories => [{:changes => {:enquirer_name => {:from => '', :to => 'John Doe'}}}]}
        enquiry = create :enquiry
        put :update, :id => enquiry.id, :enquiry => enquiry_params
        saved_enquiry = Enquiry.first
        expect(saved_enquiry['histories'].length).to eq 2
        expect(saved_enquiry['histories'].first['changes']).to eq('enquiry' => {'created' => '2014-09-26 10:10:10 UTC'})
        expect(saved_enquiry['histories'][1]['changes']).to eq('enquirer_name' => {'from' => '', 'to' => 'John Doe'})
      end
    end
  end

  describe 'GET index' do

    it 'should fetch all the enquiries' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)

      enquiry = Enquiry.new(:_id => '123')
      expect(Enquiry).to receive(:all).and_return([enquiry])

      get :index
      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json)
    end

    it 'should return 422 if query parameter with last update timestamp is not a valid timestamp' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      allow(controller).to receive(:authorize!)
      bypass_rescue
      get :index, :updated_after => 'adsflkj'

      expect(response.response_code).to eq(422)
    end

    describe 'updated after' do
      before :each do
        FormSection.all.each { |fs| fs.destroy }
        form = create(:form, :name => Enquiry::FORM_NAME)
        enquirer_name_field = build(:field, :name => 'enquirer_name')
        child_name_field = build(:field, :name => 'child_name')
        create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field])

        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
        @enquiry1 = Enquiry.create(:enquirer_name => 'John doe', :child_name => 'any child')
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 24, 16, 05, 0))
        @enquiry2 = Enquiry.create(:enquirer_name => 'David', :child_name => 'any child')
      end

      it 'should return all the records created after a specified date' do
        allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
        get :index, :updated_after => '2010-01-22 06:42:12UTC'
        enquiry_one = {:location => "http://test.host:80/api/enquiries/#{@enquiry1.id}"}
        enquiry_two = {:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}

        expect(response.body).to eq([enquiry_one, enquiry_two].to_json)
      end

      it 'should decode URI encoded params' do
        allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
        allow(Clock).to receive(:now).and_return(Time.utc(2014, 10, 3, 7, 52, 18))
        enquiry = Enquiry.create(:enquirer_name => 'John doe', :child_name => 'any child')
        fake_admin_login

        get :index, :updated_after => '2014-10-03+07%3A51%3A06UTC'

        enquiry_json = [{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json
        expect(response.body).to eq(enquiry_json)
      end

      it 'should return filter records by specified date' do
        allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
        get :index, :updated_after => '2010-01-23 06:42:12UTC'

        expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}].to_json)
      end

      it 'should filter records updated after specified date' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 26, 16, 05, 0))
        allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
        enquiry = Enquiry.all.select { |enq| enq[:enquirer_name] == 'David' }.first
        enquiry.update_attributes(:enquirer_name => 'Jones')

        get :index, :updated_after => '2010-01-25 06:42:12UTC'

        expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}].to_json)
      end
    end

  end

  describe 'GET show' do
    it 'should fetch a particular enquiry' do
      allow(controller).to receive(:authorize!)
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      enquiry = double(:to_json => 'an enquiry record')
      expect(Enquiry).to receive(:get).with('123').and_return(double(:without_internal_fields => enquiry))

      get :show, :id => '123'
      expect(response.response_code).to eq(200)
      expect(response.body).to eq('an enquiry record')
    end

    it 'should not return internal fields' do
      enquiry = build :enquiry
      allow(Enquiry).to receive(:get).with(enquiry.id).and_return(enquiry)
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      expect(enquiry).to receive(:without_internal_fields).and_return(enquiry)
      allow(controller).to receive(:authorize!)
      get :show, :id => enquiry.id
    end

    it 'should return a 404 with empty body if enquiry record does not exist' do
      allow(controller).to receive(:authorize!)
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(true)
      expect(Enquiry).to receive(:get).with('123').and_return(nil)

      get :show, :id => '123'

      expect(response.body).to eq('')
      expect(response.response_code).to eq(404)
    end
  end

  describe 'turn off enquiries sync' do
    it 'when enquiries is off should return 404' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(false)
      allow(controller).to receive(:authorize!)
      get :index
      expect(response.response_code).to eq(404)
      expect(response.body).to eq('')
    end

    it 'PUT should return 404 when enquiries is not on' do
      allow(Enquiry).to receive(:enquiries_enabled?).and_return(false)
      allow(controller).to receive(:authorize!)
      put :update, :id => 1, :enquiry => {}
      expect(response.response_code).to eq(404)
      expect(response.body).to eq("")
    end
  end
end
