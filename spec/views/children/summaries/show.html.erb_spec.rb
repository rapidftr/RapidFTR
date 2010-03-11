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

    it "should enter the information for each of those field from each of the records"
    it "should enter a balnk cell if that information is not available for a given record"

    def random_child_summary
      Summary.new("_id" => "some_id")
    end
  end
end
