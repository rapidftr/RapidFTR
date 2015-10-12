require 'spec_helper'
describe SearchController, :type => :controller do
  shared_examples 'search results' do
    it 'should render error if search is invalid' do
      get :search, :query => nil
      expect(request.flash[:error]).to eq('Please enter at least one search criteria')
    end

    it 'should search against specified model' do
      expect(Search).to receive(:for).with(search_type).and_return(search)
      get :search, :query => 'test', :search_type => search_type.name
      expect(response).to be_ok
    end

    it 'should use fulltext search with the query' do
      expect(search).to receive(:fulltext_by).with(kind_of(Array), 'some query')
      get :search, :query => 'some query', :search_type => search_type.name
      expect(response).to be_ok
    end

    it 'should authorize the user' do
      expect(@controller).to receive(:authorize!).with(:index, search_type)
      get :search, :query => 'some query', :search_type => search_type.name
      expect(response).to be_ok
    end
  end

  describe '#search' do
    context 'when searching Children' do
      let :search do
        search = instance_double('Search', :results => [])
        allow(search).to receive(:paginated).and_return(search)
        allow(search).to receive(:created_by).and_return(search)
        allow(search).to receive(:fulltext_by).and_return(search)
        allow(search).to receive(:results).and_return([])
        allow(Search).to receive(:for).with(Child).and_return(search)
        search
      end

      before :all do
        create :form, :name => Child::FORM_NAME
      end

      before :each do
        fake_field_worker_login
      end

      it_behaves_like 'search results' do
        let(:search_type) { Child }
      end

      it 'should only return children for current user' do
        expect(search).to receive(:created_by).with(@controller.current_user)

        get :search, :query => 'some query', :search_type => 'Child'
        expect(response).to be_ok
      end

      it 'should return all children if user can view all' do
        fake_admin_login
        expect(search).to_not receive(:created_by)

        get :search, :query => 'some query', :search_type => 'Child'
        expect(response).to be_ok
      end
    end

    context 'when searching Enquiries' do
      let :search do
        search = instance_double('Search', :results => [])
        allow(search).to receive(:paginated).and_return(search)
        allow(search).to receive(:created_by).and_return(search)
        allow(search).to receive(:fulltext_by).and_return(search)
        allow(search).to receive(:results).and_return([])
        allow(Search).to receive(:for).with(Enquiry).and_return(search)
        search
      end

      before :all do
        create :form, :name => Enquiry::FORM_NAME
      end

      before :each do
        fake_field_worker_login
      end

      it_behaves_like 'search results' do
        let(:search_type) { Enquiry }
      end

      it 'should return all children if user can view all' do
        fake_login_as([Permission::ENQUIRIES[:view]])
        expect(search).to_not receive(:created_by)

        get :search, :query => 'some query', :search_type => 'Enquiry'
        expect(response).to be_ok
      end
    end

    context 'when search type is unknown' do
      it 'should return status 400' do
        fake_login_as
        get :search, :query => 'some query', :search_type => 'anything'
        expect(response.status).to be 400
      end
    end

    context 'when enquiries are turned off' do
      before :each do
        SystemVariable.all.each { |variable| variable.destroy }
        @enable_enquiries = SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => '0')
      end

      after :each do
        @enable_enquiries.destroy
      end

      it 'should return status 400' do
        fake_login_as
        get :search, :query => 'some query', :search_type => 'Enquiry'
        expect(response.status).to be 400
      end
    end
  end
end
