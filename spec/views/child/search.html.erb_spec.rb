require 'spec_helper'
require 'hpricot'

describe "children/search.html.erb" do
  describe "rendering search results" do
    before :each do
      @results = Array.new(4){ |i| random_child_summary("some_id_#{i}") }
      assigns[:results] = @results
    end

    it "should render items for each record in the results" do
      render

      Hpricot(response.body).search("div[@class=profiles-list-item]").size.should == @results.length
    end

    it "should have a definition list for each record in the results" do
      render

      Hpricot(response.body).search("dl").size.should == @results.length
    end

    it "should include a column displaying thumbnails for each child if asked" do
      assigns[:show_thumbnails] = true
      render

      first_content_row = Hpricot(response.body).search("p[@class=photo]")[0]
      first_image_tag = first_content_row.at("img")
      raise 'no image tag' if first_image_tag.nil?

      first_image_tag['src'].should == child_path( @results.first, :format => 'jpg' )
      first_image_tag['width'].should == '60'
      first_image_tag['height'].should == '60'
    end

    it "should not include a column displaying thumbnails if not asked" do
      assigns[:show_thumbnails] = false
      render

      Hpricot(response.body).at("p[@class=photo]").should be_nil
    end

    it "should include checkboxes to select individual records" do
      render

      select_check_boxes = Hpricot(response.body).search("p[@class=checkbox] input[@type='checkbox']")
      select_check_boxes.length.should == @results.length
      select_check_boxes.each_with_index do |check_box,i|
        check_box['name'].should == @results[i]['_id']
      end
    end

    def random_child_summary(id = 'some_id')
      Summary.new("_id" => id, "age_is" => "Approx")
    end

  end
end
