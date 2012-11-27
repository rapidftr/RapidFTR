require 'spec_helper'

describe DatabaseController do
  before do
    fake_admin_login
  end

  after do
    Rails.env = "test"
  end
  it "should delete all children in android environment" do
    Rails.env = "android"
    Child.create('last_known_location' => "London")
    Child.create('last_known_location' => "India")
    delete :delete_children
    Child.all.should be_empty
  end

  it "should not delete children if ran in any rails environment other than android" do
    Child.create('last_known_location' => "London")
    Child.create('last_known_location' => "India")
    delete :delete_children
    Child.all.should_not be_empty
  end

end