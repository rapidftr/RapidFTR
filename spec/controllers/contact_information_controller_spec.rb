require 'spec_helper'

describe ContactInformationController do
  describe "GET edit" do
    it "populates the contact information" do
      fake_admin_login
      contact_information = {"name"=>"Bob"}
      ContactInformation.stub!(:get_or_create).with("bob").and_return(contact_information)
      get :edit, :id => "bob"
      assigns[:contact_information].should == contact_information
    end
  end
  describe "GET show" do
    it "returns JSON version of the contact information when requested" do
      @request.env["HTTP_ACCEPT"] = "application/json"
      contact_information = {"name"=>"Bob"}
      ContactInformation.stub!(:get_by_id).with("administrator").and_return(contact_information)
      get :show, :id => "administrator"
      response_as_json =  JSON.parse @response.body
      response_as_json.should == {"name"=>"Bob"}
    end
    it "should 404 if showing a contact information that does not exist" do
      fake_admin_login
      ContactInformation.stub!(:get_by_id).with("foo").and_raise(ErrorResponse.not_found("Contact information not found"))
      get :show, :id => "foo"
      response.status.should =~ /404/
    end
  end
  
end
