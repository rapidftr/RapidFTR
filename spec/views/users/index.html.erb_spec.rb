require 'spec_helper'

describe "/users/index.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:users] = [
      stub_model(User),
      stub_model(User)
    ]
  end

  it "renders a list of users" do
    render
  end
end
