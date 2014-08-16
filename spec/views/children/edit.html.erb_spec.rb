  require 'spec_helper'

  describe "children/edit.html.erb", :type => :view do

    before :each do
      @form_section = FormSection.new :unique_id => "section_name", :visible => "true"
      assign(:form_sections, [@form_section])
      allow(User).to receive(:find_by_user_name).with("me").and_return(double(:organisation => "stc"))
      @child = Child.create(:name => "name", :unique_identifier => '12341234123', :created_by => "me")
      assign(:child, @child)
      @user = User.new
      @user.stub(:permissions => Permission::USERS[:create_and_edit])
      allow(controller).to receive(:current_user).and_return(@user)
    end

    it "renders a form that posts to the children url" do
      render
      expect(rendered).to have_tag("form[action='#{child_path(@child)}']")
    end

    xit "renders the children/form_section partial" do
      # This should be a controller spec
      render
      expect(rendered).to render_template(:partial =>  "_form_section",:collection => [@form_section])
    end

    it "renders a form whose discard button links to the child listing page" do
      render
      expect(rendered).to have_tag("a[href='#{children_path}']")
    end
  end
