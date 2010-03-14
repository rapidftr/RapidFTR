require 'spec_helper'
require 'hpricot'

describe "children/search.html.erb" do
  describe "rendering search results" do
    before :each do
      @results = Array.new(4){ |i| random_child_summary("some_id_#{i}") }
      assigns[:results] = @results
    end

    it "should render table rows for the header, plus each record in the results" do
      render

      Hpricot(response.body).search("tr").size.should == @results.length + 1
    end

    it "should have a column for each of the fields in the search template" do
      render

      Hpricot(response.body).search("tr th").size.should == Templates.get_search_result_template.size
    end

    it "should include a column displaying thumbnails for each child if asked" do
      assigns[:show_thumbnails] = true
      render

      first_content_row = Hpricot(response.body).search("tr")[1]
      first_image_tag = first_content_row.at("td img")
      raise 'no image tag' if first_image_tag.nil?

      first_image_tag['src'].should == child_path( @results.first, :format => 'jpg' )
      first_image_tag['width'].should == '60'
      first_image_tag['height'].should == '60'
    end

    it "should not include a column displaying thumbnails if not asked" do
      assigns[:show_thumbnails] = false
      render

      Hpricot(response.body).at("tr td img").should be_nil
    end

    it "should include a column of checkboxes to select individual records" do
      render

      select_check_boxes = Hpricot(response.body).search("tr td input[@type='checkbox']")
      select_check_boxes.length.should == @results.length
      select_check_boxes.each_with_index do |check_box,i|
        check_box['name'].should == @results[i]['_id']
      end
    end

    def random_child_summary(id = 'some_id')
      Summary.new("_id" => id)
    end

  end
end
