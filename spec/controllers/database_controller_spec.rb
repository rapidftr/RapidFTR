require 'spec_helper'

describe DatabaseController do
  before do
    fake_admin_login
  end

  it "should delete all children in android environment" do
    Rails.env = "android"
    Child.create('last_known_location' => "London")
    Child.create('last_known_location' => "India")
    delete :delete_children
    Child.all.should be_empty
  end
end