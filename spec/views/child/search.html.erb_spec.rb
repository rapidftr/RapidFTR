require 'spec_helper'
require 'hpricot'

include HpricotSearch

describe "children/search.html.erb" do
  describe "rendering search results" do
    before :each do
      @results = Array.new(4){ |i| random_child_summary("some_id_#{i}") }
      @highlighted_fields = [ { :name => "field_2", :display_name => "field display 2" }, { :name => "field_4", :display_name => "field display 4" } ]
      assigns[:results] = @results
      assigns[:highlighted_fields] = @highlighted_fields
    end

    it "should render items for each record in the results" do
      render

      Hpricot(response.body).profiles_list_items.size.should == @results.length
    end
    
    it "should show only the highlighted fields for a child" do
      summary = Child.new(
        "_id" => "some_id", "created_by" => "dave", "last_updated_at" => Time.now.strftime("%d/%m/%Y %H:%M"),
        "field_1" => "field 1", "field_2" => "field 2", "field_3" => "field 3", "field_4" => "field 4",
        "current_photo_key" => "some-photo-id")
      summary.stub!(:has_one_interviewer?).and_return(true)
      @results = [summary]

      assigns[:results] = @results

      render

      fields = Hpricot(response.body).search(".details dl.basic")
      fields.search("dt").size.should == @highlighted_fields.size
      fields.search("dd").size.should == @highlighted_fields.size
      fields.search("dt").first.inner_text.should == "field display 2:"
      fields.search("dd").first.inner_text.should == "field 2"
    end

    it "should have a definition list for interview timestamps details for each record in the results" do
      render

      Hpricot(response.body).search(".details dl.interview-timestamp").size.should == @results.length
    end

    it "should include a column displaying thumbnails for each child if asked" do
      assigns[:show_thumbnails] = true
      render

      first_content_row = Hpricot(response.body).photos
      first_image_tag = first_content_row.at("img")
      raise 'no image tag' if first_image_tag.nil?

      child = @results.first
      first_image_tag['src'].should == "/children/#{child.id}/thumbnail/#{child.primary_photo_id}"
    end

    it "should show thumbnails with urls for child details page for each child if asked" do
      render

      first_content_row = Hpricot(response.body).photos
      first_href = first_content_row.at("a")
      first_href.should_not nil

      first_href['href'].should == "/children/#{@results.first.id}"
    end

    it "should include checkboxes to select individual records" do
      render

      select_check_boxes = Hpricot(response.body).checkboxes
      select_check_boxes.length.should == @results.length
      select_check_boxes.each_with_index do |check_box,i|
        check_box['name'].should == "selections[#{i}]"
        check_box['value'].should == @results[i]['_id']
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

    it "should have a button to export to pdf" do
      render
                
      export_to_photo_wall = Hpricot(response.body).submit_for("Export to PDF")
      export_to_photo_wall.size.should_not == 0
    end

    it "should have a button to export to photo wall" do
      render
                      
      export_to_photo_wall = Hpricot(response.body).submit_for("Export to Photo Wall")
      export_to_photo_wall.size.should_not == 0
    end

    def random_child_summary(id = 'some_id')
      summary = Child.new("_id" => id, "age_is" => "Approx", "created_by" => "dave", "last_updated_at" => Time.now.strftime("%d/%m/%Y %H:%M"), "current_photo_key" => "photo-id")
      summary.stub!(:has_one_interviewer?).and_return(true)
      summary
    end

  end
end 
