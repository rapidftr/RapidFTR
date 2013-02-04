  require 'spec_helper'

describe "children/edit.html.erb" do

  before :each do
    @form_section = FormSection.new :unique_id => "section_name", :visible=>"true"
    assign(:form_sections, [@form_section])
    @child = Child.create(:name => "name", :unique_identifier => '12341234123')
    assign(:child, @child)
    @user = User.new
    @user.stub(:permissions => Permission::USERS[:create_and_edit])
    controller.stub(:current_user).and_return(@user)
  end

  it "renders a form that posts to the children url" do
    render
    rendered.should have_tag("form[action='#{child_path(@child)}']")
  end

  it "renders the children/form_section partial" do
    render
    rendered.should render_template(:partial =>  "_form_section",:collection => [@form_section])
  end

  it "renders a form whose discard button links to the child listing page" do
    render
    rendered.should have_tag("a[href='#{children_path}']")
  end
end
