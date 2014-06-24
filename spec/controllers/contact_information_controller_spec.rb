require 'spec_helper'

describe ContactInformationController do
  describe "GET show" do
    before :each do
      controller.stub(:current_session).and_return(nil)
    end

    it "returns the JSON representation if showing a contact information that exists" do
      @request.env["HTTP_ACCEPT"] = "application/json"
      contact_information = {"name"=>"Bob"}
      ContactInformation.stub(:get_by_id).with("administrator").and_return(contact_information)

      get :show, :id => "administrator"

      response_as_json =  JSON.parse @response.body
      response_as_json.should == contact_information
    end

    it "returns a 404 response if showing a contact information that does not exist" do
      ContactInformation.stub(:get_by_id).with("foo").and_raise(ErrorResponse.not_found("Contact information not found"))

      get :show, :id => "foo"

      response.status.should == 404
    end
  end

  describe "GET edit" do
    it "populates the contact information when logged in as an admin" do
      fake_admin_login
      contact_information = {"name"=>"Bob"}
      ContactInformation.stub(:get_or_create).with("bob").and_return(contact_information)

      get :edit, :id => "bob"

      assigns[:contact_information].should == contact_information
    end
  end
end
