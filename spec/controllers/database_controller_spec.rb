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
    Child.create('last_known_location' => "London")
    Child.create('last_known_location' => "India")
    delete :delete_children
    Child.all.should be_empty
  end
end
