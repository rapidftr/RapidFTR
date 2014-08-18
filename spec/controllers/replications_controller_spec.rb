require 'spec_helper'

describe ReplicationsController, :type => :controller do

  it 'should show page name on new page' do
    fake_login_as
    get :new
    expect(assigns[:page_name]).to eq('Configure a Server')
  end

  it 'should authenticate configuration request through internal _users database of couchdb' do
    config = {'a' => 'a', 'b' => 'b', 'c' => 'c'}
    expect(CouchSettings.instance).to receive(:authenticate).with('rapidftr', 'rapidftr').and_return(true)
    expect(Replication).to receive(:couch_config).and_return(config)
    post :configuration, :user_name => 'rapidftr', :password => 'rapidftr'
    target_json = JSON.parse(response.body)
    expect(target_json).to eq(config)
  end

  it 'should render devices index page after saving a replication' do
    fake_login_as
    mock_replication = Replication.new
    expect(Replication).to receive(:new).and_return(mock_replication)
    expect(mock_replication).to receive(:save).and_return(true)
    post :create
    expect(response).to redirect_to(devices_path)
  end

end
