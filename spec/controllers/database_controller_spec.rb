require 'spec_helper'

describe DatabaseController, :type => :controller do
  before do
    fake_admin_login
  end

  before do
    @original_rails_env = Rails.env
    Rails.env = 'android'
  end

  after do
    Rails.env = @original_rails_env
  end

  it 'should delete all child models in non-production environments' do
    allow(User).to receive(:find_by_user_name).with('me').and_return(double(:organisation => 'stc'))
    Child.create('last_known_location' => 'London', :created_by => 'me')
    Child.create('last_known_location' => 'India', :created_by => 'me')

    delete :delete_data, :data_type => 'child'

    expect(Child.all).to be_empty
  end

  it 'should delete all enquiry models in non-production environments' do
    allow(User).to receive(:find_by_user_name).with('me').and_return(double(:organisation => 'stc'))
    Enquiry.create(:enquirer_name => 'Someone', :criteria => {'name' => 'child name'})
    Enquiry.create(:enquirer_name => 'Someone Else', :criteria => {'name' => 'child name'})

    delete :delete_data, :data_type => 'enquiry'

    expect(Enquiry.all).to be_empty
  end

  it 'should not delete any models in production environments' do
    Rails.env = 'production'
    delete :delete_data, :data_type => 'enquiry'
    expect(response.response_code).to eq(403)
  end
end
