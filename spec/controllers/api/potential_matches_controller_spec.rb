require 'spec_helper'

describe Api::PotentialMatchesController, :type => :controller do
  before :each do
    PotentialMatch.all.each { |pm| pm.destroy }
    fake_field_worker_login
  end

  describe 'GET index' do
    it 'should fetch all the potential matches' do
      expect(controller).to receive(:authorize!).with(:read, PotentialMatch).and_return(true)

      potential_match = PotentialMatch.new(:_id => '123')
      view = instance_double('CouchRest::Model::Designs::View', :all => [potential_match])
      expect(PotentialMatch).to receive(:all).and_return(view)

      get :index
      expect(response.response_code).to eq(200)
      expect(response.body).to eq([{:location => "http://test.host/api/potential_matches/#{potential_match.id}"}].to_json)
    end

    describe 'updated after' do

      it 'should return all the records created after a specified date' do
        expect(controller).to receive(:authorize!).with(:read, PotentialMatch).and_return(true)
        @pm1 = PotentialMatch.new :enquiry_id => 1, :child_id => 1
        @pm2 = PotentialMatch.new :enquiry_id => 1, :child_id => 2
        Timecop.freeze(1.days.ago) { @pm1.save }
        Timecop.freeze(2.days.ago) { @pm2.save }
        Timecop.freeze(4.days.ago) { PotentialMatch.create :enquiry_id => 2, :child_id => 2 }

        get :index, :updated_after => 3.days.ago.to_s

        pm1_url = {'location' => "http://test.host/api/potential_matches/#{@pm1.id}"}
        pm2_url = {'location' => "http://test.host/api/potential_matches/#{@pm2.id}"}
        json = JSON.parse response.body
        expect(json.length).to eq 2
        expect(json).to include(pm2_url, pm1_url)
      end
    end
  end

  describe 'GET show' do
    it 'should authorize user' do
      expect(controller).to receive(:authorize!).with(:read, PotentialMatch)
      get :show, :id => '1'
    end

    it 'should authorize user' do
      expect(controller).to receive(:authorize!).with(:read, PotentialMatch)
      pm1 = PotentialMatch.create :enquiry_id => 1, :child_id => 1

      get :show, :id => pm1.id
      json = JSON.parse response.body
      expected_json = JSON.parse(pm1.to_json)
      expect(Time.parse(json['created_at']).to_i).to eq(pm1['created_at'].to_i)
      expect(Time.parse(json['updated_at']).to_i).to eq(pm1['updated_at'].to_i)
      expect(json['_id']).to eq(expected_json['_id'])
      expect(json['_rev']).to eq(expected_json['_rev'])
      expect(json['enquiry_id']).to eq(expected_json['enquiry_id'])
      expect(json['child_id']).to eq(expected_json['child_id'])
      expect(json['marked_invalid']).to eq(expected_json['marked_invalid'])
    end
  end
end
