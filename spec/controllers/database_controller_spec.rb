require 'spec_helper'

describe DatabaseController do
  before do
    fake_admin_login
  end
  
  before do
    @original_rails_env = Rails.env
    Rails.env = "android"
  end

  after do
    Rails.env = @original_rails_env
  end

  it "should delete all child models in non-production environments" do
    User.stub!(:find_by_user_name).with("me").and_return(mock(:organisation => "stc"))
    Child.create('last_known_location' => "London", :created_by => "me")
    Child.create('last_known_location' => "India", :created_by => "me")
    
    delete :delete_data, :data_type => "child"
    
    Child.all.should be_empty
  end

  it "should delete all enquiry models in non-production environments" do
    User.stub!(:find_by_user_name).with("me").and_return(mock(:organisation => "stc"))
    Enquiry.create({:enquirer_name => 'Someone', :criteria => {'name' => 'child name'}})
    Enquiry.create({:enquirer_name => 'Someone Else', :criteria => {'name' => 'child name'}})
    
    delete :delete_data, :data_type => "enquiry"
    
    Enquiry.all.should be_empty
  end

  it "should not delete any models in production environments" do
    Rails.env = "production"
    expect { delete :delete_data, :data_type => "enquiry" }.to raise_error
  end  
end
