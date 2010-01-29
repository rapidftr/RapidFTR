require 'spec_helper'

describe "/children/show.html.erb" do
  include ChildrenHelper
  before(:each) do
    assigns[:child] = @child = stub_model(Child,
      :name => "value for name",
      :age => "value for age"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ age/)
  end
end
