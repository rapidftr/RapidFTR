require 'spec_helper'
require 'hpricot'

include HpricotSearch

describe "shared/_pagination.html.erb", :type => :view do
  before :each do
    @page = 1
    @per_page = 10
    @total_rows = 100
  end

  subject do
    @children = (1 .. [@per_page, @total_rows].min).to_a.map { Child.new }
    @results = WillPaginate::Collection.create(@page, @per_page, @total_rows) do |pager|
      pager.replace @children
    end

    render :partial => 'shared/pagination', :locals => {:results => @results}
    rendered
  end

  before :each do
    Rails.application.routes.stub :url_for => '#'
  end

  describe 'pagination info box' do
    it "no records" do
      @total_rows = 0
      is_expected.to have_content "No entries found"
    end

    it "1 record" do
      @total_rows = 1
      is_expected.to have_content "Displaying 1 child"
    end

    it "less records than page" do
      @total_rows = 5
      is_expected.to have_content "Displaying all 5 children"
    end

    it "more records than page" do
      is_expected.to have_content "Displaying children 1 - 10 of 100 in total"
    end

    it "next page" do
      @page = 2
      is_expected.to have_content "Displaying children 11 - 20 of 100 in total"
    end
  end

  describe 'pagination links' do
    it "no records" do
      @total_rows = 0
      is_expected.not_to have_tag "a"
    end

    it "less records than page" do
      @total_rows = 5
      is_expected.not_to have_tag "a"
    end

    it "disable previous link" do
      @page = 1
      is_expected.not_to have_link "Previous"
    end

    it "enable previous link" do
      @page = 2
      is_expected.to have_link "Previous"
    end

    it "disable next link" do
      @page = 10
      is_expected.not_to have_link "Next"
    end

    it "enable next link" do
      @page = 1
      is_expected.to have_link "Next"
    end

    it "highlight current page" do
      @page = 5
      is_expected.to have_content "5"
      is_expected.not_to have_link "5"
    end
  end
end
