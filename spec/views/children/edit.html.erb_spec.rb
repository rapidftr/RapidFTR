require 'spec_helper'

describe "/children/edit.html.erb" do
  include ChildrenHelper

  before(:each) do
    assigns[:child] = @child = stub_model(Child,
      :new_record? => false,
      :name => "value for name",
      :age => "value for age"
    )
  end

  it "renders the edit child form" do
    render

    response.should have_tag("form[action=#{child_path(@child)}][method=post]") do
      with_tag('input#child_name[name=?]', "child[name]")
      with_tag('input#child_age[name=?]', "child[age]")
    end
  end
end
