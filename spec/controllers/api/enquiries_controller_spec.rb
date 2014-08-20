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

  end

  describe '#authorizations' do
    it 'should fail to POST create when unauthorized' do
      expect(@controller.current_ability).to receive(:can?).with(:create, Enquiry).and_return(false)
      post :create
      expect(response).to be_forbidden
    end

    it 'should fail to update when unauthorized' do
      expect(@controller.current_ability).to receive(:can?).with(:update, Enquiry).and_return(false)
      test_id = '12345'
      put :update, :id => test_id, :enquiry => {:id => test_id, :enquirer_name => 'new name'}
      expect(response).to be_forbidden
    end
  end

  describe 'POST create' do

    it 'should trigger the match functionality every time a record is created' do
      allow(controller).to receive(:authorize!)
      name = 'reporter'
      details = {'location' => 'Kampala'}
      criteria = {'name' => 'Magso'}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :criteria => criteria}, :format => :json
    end

    it 'should not trigger the match unless record is created' do
      allow(controller).to receive(:authorize!)
      expect(Enquiry).not_to receive(:find_matching_children)

      post :create, :enquiry => {}

      expect(response.response_code).to eq(422)
    end

    it 'should create the enquiry record and return a success code' do
      allow(controller).to receive(:authorize!)
      name = 'reporter'

      details = {'location' => 'Kampala'}

      post :create, :enquiry => {:enquirer_name => name, :reporter_details => details, :name => 'name'}

      expect(Enquiry.all.total_rows).to eq(1)
      enquiry = Enquiry.all.first

      expect(enquiry.enquirer_name).to eq(name)
      expect(response.response_code).to eq(201)
    end

    it 'should not create enquiry without criteria' do
      allow(controller).to receive(:authorize!)
      post :create, :enquiry => {:parent_name => 'new name', :town => 'kampala'}
      expect(response.response_code).to eq(422)
      expect(JSON.parse(response.body)['error']).to include('Criteria Please add criteria to your enquiry')
    end

    it 'should not update record if it exists and return error' do
      enquiry = Enquiry.new(:enquirer_name => 'old name', :"location" => 'kampala', :name => 'name')
      enquiry.save!
      allow(controller).to receive(:authorize!)

      post :create, :enquiry => {'id' => enquiry.id, :enquirer_name => 'new name', :name => 'name'}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq('old name')
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)['error']).to eq('Forbidden')
    end
  end

  describe 'PUT update' do

    it 'should not update record when criteria is empty' do
      enquiry = Enquiry.create(:enquirer_name => 'Someone', :name => 'child name')
      allow(controller).to receive(:authorize!)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => nil, :name => nil}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should not update record when there is no criteria' do
      enquiry = Enquiry.create(:enquirer_name => 'Someone', :name => 'child name')
      allow(controller).to receive(:authorize!)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => nil, :name => nil}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should trigger the match functionality every time a record is created' do
      criteria = {'name' => 'old name'}
      enquiry = Enquiry.create(:enquirer_name => 'Machaba', :reporter_details => {'location' => 'kampala'}, :criteria => criteria)
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :criteria => criteria}, :format => :json

      expect(response.response_code).to eq(200)
    end

    it 'should not trigger the match unless record is created' do
      criteria = {'name' => 'old name'}
      enquiry = Enquiry.create(:enquirer_name => 'Machaba', :reporter_details => {'location' => 'kampala'}, :criteria => criteria)
      allow(controller).to receive(:authorize!)

      expect(Enquiry).not_to receive(:find_matching_children)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => ''}, :format => :json

      expect(response.response_code).to eq(422)
    end

    it 'should return an error if enquiry does not exist' do
      allow(controller).to receive(:authorize!)
      id = '12345'
      allow(Enquiry).to receive(:get).with(id).and_return(nil)

      put :update, :id => id, :enquiry => {:id => id, :enquirer_name => 'new name'}

      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)['error']).to eq('Not found')
    end

    it 'should merge existing criteria when sending new values in criteria' do
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.new(:enquirer_name => 'old name', :location => 'kampala', :name => 'Batman')
      enquiry.save!

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :gender => 'Male'}

      expect(response.response_code).to eq(200)
      expect(Enquiry.get(enquiry.id)[:criteria]).to eq('name' => 'Batman', 'gender' => 'Male', 'enquirer_name' => 'new name', 'location' => 'kampala')
      expect(JSON.parse(response.body)['error']).to be_nil
    end

    it 'should update record if it exists and return the updated record' do
      allow(controller).to receive(:authorize!)
      criteria = {:name => 'name'}
      enquiry = Enquiry.create(:enquirer_name => 'old name', :criteria => criteria)

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :enquirer_name => 'new name', :criteria => criteria}

      enquiry = Enquiry.get(enquiry.id)

      expect(enquiry.enquirer_name).to eq('new name')
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it 'should update record without passing the id in the enquiry params' do
      allow(controller).to receive(:authorize!)
      criteria = {:name => 'name'}
      enquiry = Enquiry.create(:enquirer_name => 'old name', :reporter_details => {'location' => 'kampala'}, :criteria => criteria)

      put :update, :id => enquiry.id, :enquiry => {:enquirer_name => 'new name', :criteria => criteria}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.enquirer_name).to eq('new name')
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it 'should merge updated fields and return the latest record' do
      allow(controller).to receive(:authorize!)
      enquiry = Enquiry.create(:enquirer_name => 'old name', :location => 'kampala', :name => 'child name')

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :name => 'child new name'}

      enquiry = Enquiry.get(enquiry.id)
      expect(enquiry.criteria).to eq('name' => 'child new name', 'enquirer_name' => 'old name', 'location' => 'kampala')

      put :update, :id => enquiry.id, :enquiry => {:id => enquiry.id, :location => 'Kampala', :age => '100', :gender => 'female'}

      enquiry = Enquiry.get(enquiry.id)

      expect(enquiry.criteria).to eq('name' => 'child new name', 'gender' => 'female', 'enquirer_name' => 'old name', 'location' => 'Kampala', 'age' => '100')
      expect(enquiry['age']).to eq('100')
      expect(enquiry['location']).to eq('Kampala')
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(enquiry.to_json))
    end

    it 'should update existing enquiry with potential matches', :solr => true do
      reset_couchdb!
      form = create :form, :name => Enquiry::FORM_NAME
      create :form_section, :fields => [
        build(:text_field, :name => 'name'),
        build(:text_field, :name => 'age'),
        build(:text_field, :name => 'location'),
        build(:text_field, :name => 'sex')
      ], :form => form

      Child.reindex!

      allow(controller).to receive(:authorize!)
      child1 = Child.create('name' => 'Clayton aquiles', 'created_by' => 'fakeadmin', 'created_organisation' => 'stc')
      child2 = Child.create('name' => 'Steven aquiles', 'sex' => 'male', 'created_by' => 'fakeadmin', 'created_organisation' => 'stc')

      enquiry_json = "{\"enquirer_name\": \"Godwin\",\"sex\": \"male\",\"age\": \"10\",\"location\": \"Kampala\" }"
      enquiry = Enquiry.new(JSON.parse(enquiry_json))
      enquiry.save!
      expect(Enquiry.get(enquiry.id)['potential_matches']).to include(*[child2.id])

      updated_enquiry = "{\"name\": \"aquiles\", \"age\": \"10\", \"location\": \"Kampala\"}"

      put :update, :id => enquiry.id, :enquiry => updated_enquiry
      expect(response.response_code).to eq(200)

      enquiry_after_update = Enquiry.get(enquiry.id)
      expect(enquiry_after_update['potential_matches'].size).to eq(2)
      expect(enquiry_after_update['potential_matches'].include?(child1.id)).to eq(true)
      expect(enquiry_after_update['potential_matches'].include?(child2.id)).to eq(true)
      # enquiry_after_update['potential_matches'].size.should == [child2.id,child1.id]
      expect(enquiry_after_update['criteria']).to eq('name' => 'aquiles', 'age' => '10', 'location' => 'Kampala', 'sex' => 'male')
    end

  end

  describe 'GET index' do

    it 'should fetch all the enquiries' do
      allow(controller).to receive(:authorize!)

      enquiry = Enquiry.new(:_id => '123')
      expect(Enquiry).to receive(:all).and_return([enquiry])

      get :index
      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{enquiry.id}"}].to_json)
    end

    it 'should return 422 if query parameter with last update timestamp is not a valid timestamp' do
      allow(controller).to receive(:authorize!)
      bypass_rescue
      get :index, :updated_after => 'adsflkj'

      expect(response.response_code).to eq(422)
    end

    describe 'updated after' do
      before :each do 
        FormSection.all.each {|fs| fs.destroy }
        form = create(:form, :name => Enquiry::FORM_NAME)
        enquirer_name_field = build(:field, :name => 'enquirer_name')
        child_name_field = build(:field, :name => 'child_name')
        form_section = create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field])


        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
        @enquiry1 = Enquiry.create(:enquirer_name => 'John doe',:child_name => 'any child')
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 24, 16, 05, 0))
        @enquiry2 = Enquiry.create(:enquirer_name => 'David',:child_name => 'any child')
      end

      it'should return all the records created after a specified date' do
        get :index, :updated_after => '2010-01-22 06:42:12UTC'
        
        enquiry_one = {:location => "http://test.host:80/api/enquiries/#{@enquiry1.id}"}
        enquiry_two = {:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}
        expect(response.body).to match([enquiry_one, enquiry_two].to_json)
      end

      it'should return filter records by specified date' do
        get :index, :updated_after => '2010-01-23 06:42:12UTC'
        
        expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}].to_json)
      end

      it 'should filter records updated after specified date' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 26, 16, 05, 0))
        enquiry = Enquiry.all.select{|enquiry| enquiry[:enquirer_name] == 'David'}.first
        enquiry.update_attributes({:enquirer_name => 'Jones'})

        get :index, :updated_after => '2010-01-25 06:42:12UTC'
        
        expect(response.body).to eq([{:location => "http://test.host:80/api/enquiries/#{@enquiry2.id}"}].to_json)
      end
    end

  end

  describe 'GET show' do
    it 'should fetch a particular enquiry' do
      allow(controller).to receive(:authorize!)

      expect(Enquiry).to receive(:get).with('123').and_return(double(:to_json => 'an enquiry record'))

      get :show, :id => '123'
      expect(response.response_code).to eq(200)
      expect(response.body).to eq('an enquiry record')
    end

    it 'should return a 404 with empty body if enquiry record does not exist' do
      allow(controller).to receive(:authorize!)

      expect(Enquiry).to receive(:get).with('123').and_return(nil)

      get :show, :id => '123'

      expect(response.body).to eq('')
      expect(response.response_code).to eq(404)
    end

  end

end
