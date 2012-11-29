require 'spec_helper'

describe 'children/_footer.html.erb' do

  before :each do
    @user = User.new
    controller.stub(:current_user).and_return(@user)
  end

  shared_examples_for "show links" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/footer"
      p "***", rendered, "**",have_tag("a[href='#{@url}']")
      rendered.should have_tag("a[href='#{@url}']")
    end
  end

  shared_examples_for "not show links" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/footer"
      p "###",@url
      rendered.should_not have_tag("a[href='#{@url}']")
    end
  end

  describe "export some records to CSV" do
    before :each do
      @url = new_advanced_search_path
    end

    it_should_behave_like "not show links", []
    it_should_behave_like "show links", [ Permission::CHILDREN[:export] ]
  end

  describe "export all records to CSV" do
    before :each do
      @url = children_path(:format => :csv)
    end

    it_should_behave_like "not show links", []
    it_should_behave_like "not show links", [ Permission::CHILDREN[:export] ]
    it_should_behave_like "show links", [ Permission::CHILDREN[:export], Permission::CHILDREN[:view_and_search] ]
  end

  describe "export all records to PDF" do
    before :each do
      @url = children_path(:format => :csv)
    end

    it_should_behave_like "not show links", []
    it_should_behave_like "not show links", [ Permission::CHILDREN[:export] ]
    it_should_behave_like "show links", [ Permission::CHILDREN[:export], Permission::CHILDREN[:view_and_search] ]
  end

end