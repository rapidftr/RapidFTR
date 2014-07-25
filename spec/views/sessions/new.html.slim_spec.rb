require 'spec_helper'

describe "/sessions/new.html.slim", :type => :view do
  it "should have a 'Request Password Reset' link" do
    render
    expect(rendered).to have_tag("a")
  end
end
