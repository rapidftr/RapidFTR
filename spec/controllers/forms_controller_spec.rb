require 'spec_helper'

describe FormsController, :type => :controller do
  before :each do
    reset_couchdb!
  end

  describe '.index' do
    it 'should assign all Forms for use in the view' do
      enquiry_form = create :form, :name => Enquiry::FORM_NAME
      children_form = create :form, :name => Child::FORM_NAME
      fake_admin_login
      get :index
      expect(assigns[:forms]).to contain_exactly(enquiry_form, children_form)
    end
  end

  describe '.bulk_update' do
    it 'should use the StandardFormsService to persist data' do
      fake_admin_login
      params = {:default_forms => 'some_forms'}
      expect(StandardFormsService).to receive(:persist).with('some_forms')
      post :bulk_update, params
    end
  end
end
