require 'spec_helper'

describe "/children/new.html.erb" do
  include ChildrenHelper

  before(:each) do
    assigns[:child] = stub_model(Child,
      :new_record? => true,
      :name => "value for name",
      :age => "value for age"
    )
  end

  it "renders new child form" do
    render

    response.should have_tag("form[action=?][method=post]", children_path) do
      with_tag("input#child_name[name=?]", "child[name]")
      with_tag("input#child_age[name=?]", "child[age]")
    end
  end
end
