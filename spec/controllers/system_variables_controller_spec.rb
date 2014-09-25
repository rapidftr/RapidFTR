require 'spec_helper'

describe SystemVariablesController, :type => :controller do

  before :each do
    fake_admin_login
    SystemVariable.all.all.each(&:destroy)
  end

  it 'should render the defined system variables' do
    variable1 = SystemVariable.create(:name => 'Testing', :value => '23')
    variable2 = SystemVariable.create(:name => 'Testing2', :value => '23323')

    get(:index)

    expect(assigns[:system_variables]).to include(variable1, variable2)
  end

  it 'should update defined system variables' do
    variable = SystemVariable.create(:name => 'Testing', :value => '2343')

    params = {:system_variables => {variable.id => '23'}}
    put :update, params
    expect(SystemVariable.all.first.value).to eq('23')
  end

  it 'should trigger update of potential matches when the score threshold changes.' do
    variable = SystemVariable.create(:name => SystemVariable::SCORE_THRESHOLD, :value => '2343')
    params = {:system_variables => {variable.id => '23'}}
    Enquiry.should_receive(:update_all_child_matches)
    put :update, params
  end

  it 'should not trigger an update of potential matches when the other variables are updated' do
    variable = SystemVariable.create(:name => 'Testing', :value => '2343')
    params = {:system_variables => {variable.id => '23'}}
    Enquiry.should_not_receive(:update_all_child_matches)
    put :update, params
  end

  it 'should not trigger an update for potential matches when the score threshold value doesnot change' do
    variable = SystemVariable.create(:name => SystemVariable::SCORE_THRESHOLD, :value => '2343')
    params = {:system_variables => {variable.id => '2343'}}
    Enquiry.should_not_receive(:update_all_child_matches)
    put :update, params
  end
end
