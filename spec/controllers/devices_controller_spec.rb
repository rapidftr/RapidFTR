require 'spec_helper'

describe DevicesController, :type => :controller do

  describe 'GET index' do
    it 'fetches all the blacklisted devices but not the replication details if user have only black listed permission' do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double(:user_name => 'someone')
      expect(Device).to receive(:view).with('by_imei').and_return([device])
      expect(Replication).not_to receive(:all)
      get :index
      expect(assigns[:devices]).to eq([device])
    end

    it 'should not show black listed devices, if the user have only manage replication permission' do
      fake_login_as(Permission::DEVICES[:replications])
      expect(Device).not_to receive(:view).with('by_imei')
      expect(Replication).to receive(:all)
      get :index
    end

    it 'should show black listed devices and the replications if the user have both the permissions' do
      fake_login_as([Permission::DEVICES[:replications], Permission::DEVICES[:black_list]].flatten)
      expect(Replication).to receive(:all)
      expect(Device).to receive(:view)
      get :index
    end
  end
  describe 'POST update_blacklist' do
    it 'should update the blacklist flag' do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double
      expect(Device).to receive(:find_by_device_imei).with('123').and_call_original
      expect(Device).to receive(:by_imei).with(:key => '123').and_return([device])
      expect(device).to receive(:update_attributes).with(:blacklisted => true).and_return(true)
      post :update_blacklist, :imei => '123', :blacklisted => 'true'
      expect(response.body).to eq("{\"status\":\"ok\"}")
    end

    it 'should return failure if blacklist fails' do
      fake_login_as(Permission::DEVICES[:black_list])
      device = double
      expect(Device).to receive(:find_by_device_imei).with('123').and_call_original
      expect(Device).to receive(:by_imei).with(:key => '123').and_return([device])
      expect(device).to receive(:update_attributes).with(:blacklisted => true).and_return(false)
      post :update_blacklist, :imei => '123', :blacklisted => 'true'
      expect(response.body).to eq("{\"status\":\"error\"}")
    end

    it 'should not update the device by user without blacklist permission' do
      fake_login_as(Permission::USERS[:create_and_edit])
      expect(Device).not_to receive(:view).with('by_imei')
      post :update_blacklist, :imei => '123', :blacklisted => 'true'
      expect(response.status).to eq(403)
    end
  end

end
