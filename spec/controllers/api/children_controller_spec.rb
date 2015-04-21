require 'spec_helper'

describe Api::ChildrenController, :type => :controller do

  before :each do
    fake_admin_login
  end

  describe '#authorizations' do
    it 'should fail GET index when unauthorized' do
      expect(@controller.current_ability).to receive(:can?).with(:index, Child).and_return(false)
      get :index
      expect(response).to be_forbidden
    end

    it 'should fail GET show when unauthorized' do
      expect(@controller.current_ability).to receive(:can?).with(:show, Child).and_return(false)
      get :show, :id => '123'
      expect(response).to be_forbidden
    end

    it 'should fail to POST create when unauthorized' do
      expect(@controller.current_ability).to receive(:can?).with(:create, Child).and_return(false)
      post :create
      expect(response).to be_forbidden
    end
  end

  describe 'GET index' do
    it 'should render all children as json' do
      allow(controller).to receive(:authorize)

      child = Child.new(:_id => '123')
      expect(Child).to receive(:all).and_return([child])

      get :index

      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host:80/api/children/#{child.id}"}].to_json)
    end
  end

  describe 'updated after' do
    before :each do
      reset_couchdb!
      FormSection.all.each { |fs| fs.destroy }
      form = create(:form, :name => Child::FORM_NAME)
      child_name_field = build(:field, :name => 'child_name')
      location_field = build(:field, :name => 'location')
      create(:form_section, :name => 'basic_details', :form => form, :fields => [child_name_field, location_field])
      allow(User).to receive(:find_by_user_name).with('uname').and_return(@user = double('user', :user_name => 'uname', :organisation => 'org'))

      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
      @child1 = Child.new_with_user_name(@user, :child_name => 'John Doe', :location => 'Kampala')
      @child1.save!

      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 24, 14, 05, 0))
      @child2 = Child.new_with_user_name(@user, :child_name => 'David', :location => 'Kampala')
      @child2.save!
    end

    it 'should return all records created after a specified date' do
      get :index, :updated_after => '2010-01-22 06:42:12UTC'
      child_one = {:location => "http://test.host:80/api/children/#{@child1.id}"}
      child_two = {:location => "http://test.host:80/api/children/#{@child2.id}"}

      expect(response.body).to eq([child_one, child_two].to_json)
    end

    it 'should decode URI encoded strings' do
      allow(Clock).to receive(:now).and_return(Time.utc(2014, 10, 3, 7, 52, 18))
      child = Child.new_with_user_name(@user, :child_name => 'David', :location => 'Kampala')
      child.save!
      fake_admin_login

      get :index, :updated_after => '2014-10-03+07%3A51%3A06UTC'

      child_json = [{:location => "http://test.host:80/api/children/#{child.id}"}].to_json
      expect(response.body).to eq(child_json)
    end

    it 'should return filtered records by specified date' do
      get :index, :updated_after => '2010-01-23 06:42:12UTC'
      expect(response.body).to eq([{:location => "http://test.host:80/api/children/#{@child2.id}"}].to_json)
    end

    it 'should filter records updated after specified date' do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 26, 16, 05, 0))
      child = Child.all.select { |c| c[:child_name] == 'David' }.first

      child.update_properties_with_user_name(@user.user_name, nil, nil, nil, :child_name => 'James')
      child.save

      get :index, :updated_after => '2010-01-25 06:42:12UTC'
      expect(response.body).to eq([{:location => "http://test.host:80/api/children/#{@child2.id}"}].to_json)
    end
  end

  describe 'GET show' do
    it 'should render a child record as json' do
      expect(Child).to receive(:get).with('123').and_return(double(:without_internal_fields => double(:to_json => 'a child record')))
      get :show, :id => '123', :format => 'json'
      expect(response.body).to eq('a child record')
    end

    it 'should return a 404 with empty body if no child record is found' do
      expect(Child).to receive(:get).with('123').and_return(nil)
      get :show, :id => '123', :format => 'json'
      expect(response.response_code).to eq(404)
      expect(response.body).to eq('')
    end

    it 'should return a 403 if the device is blacklisted' do
      expect(controller).to receive(:check_device_blacklisted) { fail ErrorResponse.forbidden('Device Blacklisted') }
      get :show, :id => '123', :format => 'json'
      expect(response.response_code).to eq(403)
    end
  end

  describe 'POST create' do
    it 'should update the child record instead of creating if record already exists' do
      allow(User).to receive(:find_by_user_name).with('uname').and_return(user = double('user', :user_name => 'uname', :organisation => 'org'))
      child = Child.new_with_user_name(user, :name => 'old name')
      child.save!
      allow(controller).to receive(:authorize!)

      post :create, :child => {:unique_identifier => child.unique_identifier, :name => 'new name'}

      updated_child = Child.by_short_id(:key => child.short_id)
      expect(updated_child.rows.size).to eq(1)
      expect(updated_child.first.name).to eq('new name')
    end

    it 'should not duplicate histories from params' do
      child = {:enquirer_name => 'John Doe',
               :histories => [{:changes => {:enquirer_name => {:from => '', :to => 'John Doe'}}}]}
      post :create, :child => child
      saved_child = Child.first
      expect(saved_child['histories'].length).to eq 1
      expect(saved_child['histories'].first['changes']).to eq('enquirer_name' => {'from' => '', 'to' => 'John Doe'})
    end

    it 'should not return histories' do
      child = {:enquirer_name => 'John Doe',
               :histories => [{:changes => {:enquirer_name => {:from => '', :to => 'John Doe'}}}]}
      post :create, :child => child
      expect(response.body['histories']).to be_nil
    end
  end

  describe 'PUT update' do
    it 'should allow a records ID to be specified to create a new record with a known id' do
      new_uuid = UUIDTools::UUID.random_create
      put :update, :id => new_uuid.to_s, :child => {:id => new_uuid.to_s, :_id => new_uuid.to_s, :last_known_location => 'London', :age => '7'}

      expect(Child.get(new_uuid.to_s)[:unique_identifier]).not_to be_nil
    end

    it 'should not duplicate or replace histories from params' do
      child = create :child
      params = {:child_name => 'John Doe',
                :first_name => 'John',
                :histories => [{:changes => {:child_name => {:from => '', :to => 'John Doe'}}}]}
      put :update, :id => child.id, :child => params
      saved_child = Child.find child.id
      expect(saved_child['histories'].length).to eq 2
      expect(saved_child['histories'].first['changes']).to eq('child' => {'created' => nil})
      expect(saved_child['histories'][1]['changes']).to eq('child_name' => {'from' => '', 'to' => 'John Doe'})
    end

    it 'should not return histories' do
      child = create :child
      params = {:child_name => 'John Doe',
                :first_name => 'John',
                :histories => [{:changes => {:child_name => {:from => '', :to => 'John Doe'}}}]}
      put :update, :id => child.id, :child => params
      expect(response.body['histories']).to be_nil
    end
  end

  describe '#unverified' do
    before :each do
      @user = build :user, :verified => false, :role_ids => []
      fake_login @user
    end

    it 'should mark all children created as verified/unverifid based on the user' do
      @user.verified = true
      expect(Child).to receive(:new_with_user_name).with(@user, 'name' => 'timmy', 'verified' => @user.verified?).and_return(child = Child.new)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => 'timmy'}

      @user.verified = true
    end

    it 'should set the created_by name to that of the user matching the params' do
      expect(Child).to receive(:new_with_user_name).and_return(child = Child.new)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => 'timmy'}

      expect(child['created_by_full_name']).to eq @user.full_name
    end

    it 'should update the child instead of creating new child everytime' do
      child = Child.new
      view = double(CouchRest::Model::Designs::View)
      expect(Child).to receive(:by_short_id).with(:key => '1234567').and_return(view)
      expect(view).to receive(:first).and_return(child)
      expect(controller).to receive(:update_child_from).and_return(child)
      expect(child).to receive(:save).and_return true

      post :unverified, :child => {:name => 'timmy', :unique_identifier => '12345671234567'}

      expect(child['created_by_full_name']).to eq @user.full_name
    end

    it 'should not return histories for existing children' do
      child = double(Child)
      expect(Child).to receive(:get).and_return(child)
      expect(child).to receive(:update_with_attachments).and_return(child)
      expect(child).to receive(:save).and_return(child)
      expect(child).to receive(:without_internal_fields)
      post :unverified, :child => {:name => 'timmy', :_id => '1'}
      expect(response.body['histories']).to be_nil
    end

    it 'should not return histories for new children' do
      post :unverified, :child => {:name => 'timmy'}
      expect(response.body['histories']).to be_nil
    end
  end
end
