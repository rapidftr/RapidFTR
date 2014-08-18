require 'spec_helper'

describe SystemLogsController, :type => :controller do

  before :each do
    fake_login_as(Permission::SYSTEM[:system_users])
  end

  it 'should render index with correct page name' do
    get :index

    expect(response).to render_template :index
    expect(assigns[:page_name]).to eq('System Logs')
  end

  it 'should assign all log entries to the view, ordered by the newest first' do
    expect(LogEntry).to receive(:by_created_at).with(:descending => true).and_return 'all the log entries'

    get :index

    expect(assigns(:log_entries)).to eq('all the log entries')
  end

  it 'should only allow access to users with system settings permission' do
    expect(@controller.current_ability).to receive(:can?).with(:manage, SystemUsers).and_return(false)

    get :index

    expect(response.code).to eq('403')
  end

end
