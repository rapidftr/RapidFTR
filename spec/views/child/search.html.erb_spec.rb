require 'spec_helper'
require 'hpricot'

include HpricotSearch

describe "children/search.html.erb" do
  describe "rendering search results" do
    before :each do
      @results = Array.new(4){ |i| random_child_summary("some_id_#{i}") }
      assigns[:results] = @results
    end

    it "should render items for each record in the results" do
      render

      Hpricot(response.body).profiles_list_items.size.should == @results.length
    end

    it "should have a definition list for each record in the results" do
      render

      Hpricot(response.body).definition_lists.size.should == @results.length
    end

    it "should include a column displaying thumbnails for each child if asked" do
      assigns[:show_thumbnails] = true
      render

      first_content_row = Hpricot(response.body).photos
      first_image_tag = first_content_row.at("img")
      raise 'no image tag' if first_image_tag.nil?

      first_image_tag['src'].should == "/children/#{@results.first.id}/thumbnail"
    end

    it "should show thumbnails with urls for child details page for each child if asked" do
      assigns[:show_thumbnails] = true
      render

      first_content_row = Hpricot(response.body).photos
      first_href = first_content_row.at("a")
      raise 'no image tag' if first_href.nil?

      first_href['href'].should == "/children/#{@results.first.id}"
    end

    it "should not include a column displaying thumbnails if not asked" do
      assigns[:show_thumbnails] = false
      render

      Hpricot(response.body).photos.size.should be(0)
    end

    it "should include checkboxes to select individual records" do
      render

      select_check_boxes = Hpricot(response.body).checkboxes
      select_check_boxes.length.should == @results.length
      select_check_boxes.each_with_index do |check_box,i|
        check_box['name'].should == @results[i]['_id']
      end
    end
	
	it "should include a view link for each record in the result" do
      render

      view_links = Hpricot(response.body).link_for("View")
      view_links.length.should == @results.length
      view_links.each_with_index do |link,i|
        link['href'].should == "/children/#{@results[i]['_id']}"
      end
    end

    def random_child_summary(id = 'some_id')
      Summary.new("_id" => id, "age_is" => "Approx")
    end

  end
end
