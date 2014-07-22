require 'spec_helper'

describe FormsController, :type => :controller do
  describe ".index" do
    it "should assign all Forms for use in the view" do
      enquiry_form = create :form, name: "Enquiry"
      children_form = create :form, name: "Children"
      fake_admin_login
      get :index
      expect(assigns[:forms]).to contain_exactly(enquiry_form, children_form)
    end
  end
end