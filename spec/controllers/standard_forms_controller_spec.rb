require 'spec_helper'

describe StandardFormsController, :type => :controller do

  describe '#index' do
    it 'should assign to @form' do
      fake_admin_login
      expect(Forms::StandardFormsForm).to receive(:build_from_seed_data).and_return(:my_form)
      get :index
      expect(assigns[:form]).to be(:my_form)
    end
  end
end
