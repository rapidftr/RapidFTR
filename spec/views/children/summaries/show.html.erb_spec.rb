require 'spec_helper'
require 'hpricot'

describe "children/summaries/show.html.erb" do
  describe "rendering search results" do
    before :each do
      @results = [random_child_summary, random_child_summary, random_child_summary]
      assigns[:results] = @results
    end

    it "should render table rows for the header, plus each record in the results" do
      render

      Hpricot(response.body).search("tr").size.should == 4
    end

    it "should have a column for each of the fields in the search template" do
      render

      Hpricot(response.body).search("tr th").size.should == Templates.get_search_result_template.size
    end

    it "should include a column displaying thumbnails for each child" do
      render

      first_content_row = Hpricot(response.body).search("tr")[1]
      first_image_tag = first_content_row.at("td img")
      raise 'no image tag' if first_image_tag.nil?

      first_image_tag['src'].should == child_path( @results.first, :format => 'jpg' )
      first_image_tag['width'].should == '60'
      first_image_tag['height'].should == '60'
    end

    it "should enter the information for each of those field from each of the records"
    it "should enter a balnk cell if that information is not available for a given record"

    def random_child_summary
      Summary.new("_id" => "some_id")
    end
  end
end
