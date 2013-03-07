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

  it "should delete all children in android environment" do
    User.stub!(:find_by_user_name).with("me").and_return(mock(:organisation => "stc"))
    Child.create('last_known_location' => "London", :created_by => "me")
    Child.create('last_known_location' => "India", :created_by => "me")
    
    delete :delete_children
    
    Child.all.should be_empty
  end
end
