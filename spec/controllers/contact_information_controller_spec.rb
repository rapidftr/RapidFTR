require 'spec_helper'

describe ContactInformationController do
  before do
    fake_admin_login
  end
  describe "GET edit" do
    it "populates the contact information" do
      contact_information = {"name"=>"Bob"}
      ContactInformation.stub!(:get_by_id).with("administrator").and_return(contact_information)
      get :edit, :id => "administrator"
      assigns[:contact_information].should == contact_information
    end
  end

end
