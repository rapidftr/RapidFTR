require 'spec_helper'

describe '/sessions/new.html.erb', :type => :view do
  it "should have a 'Request Password Reset' link" do
    render
    expect(rendered).to have_tag('a')
  end
end
