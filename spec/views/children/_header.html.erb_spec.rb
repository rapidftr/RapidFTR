require 'spec_helper'

describe "children/_header.html.erb" do
  before :each do
    @user = User.new
    controller.stub(:current_user).and_return(@user)
    view.stub(:current_user).and_return(@user)
  end

  shared_examples_for "show links" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should have_tag("a[href='#{@url}']")
    end
  end

  shared_examples_for "not show links" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should_not have_tag("a[href='#{@url}']")
    end
  end

  shared_examples_for "show links with per_page" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should have_tag("a[href='#{@url}?per_page=all']")
    end
  end

  shared_examples_for "not show links with per_page" do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should_not have_tag("a[href='#{@url}?per_page=all']")
    end
  end

  describe "export button" do
    it "should show export button when there are children" do
      @child = FactoryGirl.create(:child)
      assign :children, @child
      permissions =   [Permission::CHILDREN[:export_csv],
                       Permission::CHILDREN[:view_and_search]]
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should have_tag("div[class='btn dropdown_btn']")
    end

    it "should not show export button when there are no children" do
      permissions =   [Permission::CHILDREN[:export_csv],
                       Permission::CHILDREN[:view_and_search]]
      @user.stub(:permissions => permissions)
      render :partial => "children/header"
      rendered.should_not have_tag("div[class='btn dropdown_btn']")
    end


  end

  describe "export all records to CSV" do
    before :each do
      @url = children_path(:format => :csv)
      @child = FactoryGirl.create(:child)
      assign :children, @child
    end

    it_should_behave_like "not show links with per_page", []
    it_should_behave_like "show links with per_page", [Permission::CHILDREN[:export_csv],
                                                       Permission::CHILDREN[:view_and_search]]
  end

  describe "export all records to PDF" do
    before :each do
      @url = children_path(:format => :pdf)
      @child = FactoryGirl.create(:child)
      assign :children, @child
    end

    it_should_behave_like "not show links with per_page", []
    it_should_behave_like "show links with per_page", [Permission::CHILDREN[:export_pdf],
                                                       Permission::CHILDREN[:view_and_search]]
  end
end
