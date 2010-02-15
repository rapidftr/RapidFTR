require 'spec_helper'

describe "/users/show.html.erb" do
  include UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(User)
  end

  it "renders attributes in <p>" do
    render
  end
end
