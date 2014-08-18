require 'spec_helper'

describe 'children/_header.html.erb', :type => :view do
  before :each do
    @user = User.new
    allow(controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
  end

  shared_examples_for 'show links' do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => 'children/header'
      expect(rendered).to have_tag("a[href='#{@url}']")
    end
  end

  shared_examples_for 'not show links' do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => 'children/header'
      expect(rendered).not_to have_tag("a[href='#{@url}']")
    end
  end

  shared_examples_for 'show links with per_page' do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => 'children/header'
      expect(rendered).to have_tag("a[href='#{@url}?per_page=all']")
    end
  end

  shared_examples_for 'not show links with per_page' do |permissions|
    it do
      @user.stub(:permissions => permissions)
      render :partial => 'children/header'
      expect(rendered).not_to have_tag("a[href='#{@url}?per_page=all']")
    end
  end

  describe 'export all records to CSV' do
    before :each do
      @url = children_path(:format => :csv)
      @children = random_child_array
    end

    it_should_behave_like 'not show links with per_page', []
    it_should_behave_like 'show links with per_page', [Permission::CHILDREN[:export_csv],
                                                       Permission::CHILDREN[:view_and_search]]
  end

  describe 'export all records to PDF' do
    before :each do
      @url = children_path(:format => :pdf)
      @children = random_child_array
    end

    it_should_behave_like 'not show links with per_page', []
    it_should_behave_like 'show links with per_page', [Permission::CHILDREN[:export_pdf],
                                                       Permission::CHILDREN[:view_and_search]]
  end

  describe 'export to CSV with no records' do
    before :each do
      @url = children_path(:format => :csv)
      @children = []
    end

    it_should_behave_like 'not show links with per_page', []
    it_should_behave_like 'not show links with per_page', [Permission::CHILDREN[:export_pdf],
                                                           Permission::CHILDREN[:view_and_search]]
  end

  describe 'export to PDF with no records' do
    before :each do
      @url = children_path(:format => :pdf)
      @children = []
    end

    it_should_behave_like 'not show links with per_page', []
    it_should_behave_like 'not show links with per_page', [Permission::CHILDREN[:export_pdf],
                                                           Permission::CHILDREN[:view_and_search]]
  end

  def random_child_array
    Array.new(3) do
      child = Child.create('created_by' => 'dave')
      child.create_unique_id
      child
    end
  end
end
