require 'spec_helper'

describe EnquiryHistoriesController, :type => :controller do
  before do
    fake_admin_login
  end

  it 'should create enquiry variable for view' do
    enquiry = create :enquiry, :created_by => controller.current_user_name
    get :index, :id => enquiry.id
    expect(assigns(:enquiry)).to eq(enquiry)
  end

  it 'should set the page name to the enquiry short ID' do
    enquiry = create :enquiry, :unique_identifier => '1234', :created_by => controller.current_user_name
    get :index, :id => enquiry.id
    expect(assigns(:page_name)).to eq('History of 1234')
  end

end
