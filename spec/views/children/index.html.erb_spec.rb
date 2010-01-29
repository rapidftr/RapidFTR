require 'spec_helper'

describe "/children/index.html.erb" do
  include ChildrenHelper

  before(:each) do
    assigns[:children] = [
      stub_model(Child,
        :name => "value for name",
        :age => "value for age"
      ),
      stub_model(Child,
        :name => "value for name",
        :age => "value for age"
      )
    ]
  end

  it "renders a list of children" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for age".to_s, 2)
  end
end
