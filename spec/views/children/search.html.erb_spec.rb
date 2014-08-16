require 'spec_helper'
require 'hpricot'

include HpricotSearch

describe "children/search.html.erb", :type => :view do
  describe "rendering search results" do
    before :each do
      @user = double(:user)
      allow(@user).to receive(:time_zone).and_return TZInfo::Timezone.get("UTC")
      allow(@user).to receive(:localize_date).and_return("some date")
      allow(@user).to receive(:has_permission?).and_return(true)
      allow(controller).to receive(:current_user).and_return(@user)
      allow(view).to receive(:current_user).and_return(@user)
      
      @results = Array.new(4){ |i| random_child_summary("some_id_#{i}") }
      @results.stub :total_entries => 100, :offset => 1, :total_pages => 10, :current_page => 1

      @highlighted_fields = [
        Field.new(:name => "field_2", :display_name => "field display 2", :visible => true ),
        Field.new(:name => "field_4", :display_name => "field display 4", :visible => true ) ]
      allow(Form).to receive(:find_by_name).and_return(double("Form", :sorted_highlighted_fields => @highlighted_fields))  
      assign(:current_user, @user)
      assign(:results, @results)
    end

    it "should render items for each record in the results" do
      render
      expect(Hpricot(rendered).profiles_list_items.size).to eq(@results.length)
    end

    it "should show only the highlighted fields for a child" do
      child = Child.create(
      "_id" => "some_id", "created_by" => "dave",
      "last_updated_at" => time_now(),
      "created_at" => time_now(),
      "field_1" => "field 1", "field_2" => "field 2", "field_3" => "field 3", "field_4" => "field 4",
      "current_photo_key" => "some-photo-id")
      allow(child).to receive(:has_one_interviewer?).and_return(true)
      child.create_unique_id
      @results.clear
      @results << child
      assign(:results, @results)

      render

      fields = Hpricot(rendered).search(".summary_panel")
      expect(fields.search(".summary_item").size).to eq(@highlighted_fields.size + 2) #including the registered by and last_updated_by keys

      expect(fields.search(".key").first.inner_text).to eq("Field Display 2:")
      expect(fields.search(".value").first.inner_text).to eq("field 2")
    end

    it "should include a column displaying thumbnails for each child if asked" do
      assign(:show_thumbnails, true)

      render

      first_content_row = Hpricot(rendered).photos
      first_image_tag = first_content_row.at("img")
      raise 'no image tag' if first_image_tag.nil?

      child = @results.first
      expect(first_image_tag['src']).to eq("/children/#{child.id}/thumbnail/#{child.primary_photo_id}")
    end

    it "should show thumbnails with urls for child details page for each child if asked" do
      render

      first_content_row = Hpricot(rendered).photos
      first_href = first_content_row.at("a")
      expect(first_href).not_to be nil

      expect(first_href['href']).to eq("/children/#{@results.first.id}")
    end

    it "should include checkboxes to select individual records" do
      render

      select_check_boxes = Hpricot(rendered).checkboxes
      expect(select_check_boxes.length).to eq(@results.length)
      select_check_boxes.each_with_index do |check_box,i|
        expect(check_box['name']).to eq("selections[#{i}]")
        expect(check_box['value']).to eq(@results[i]['_id'])
      end
    end

    it "should have a button to export to pdf" do
      render

      export_to_photo_wall = Hpricot(rendered).submit_for("Export Selected to PDF")
      expect(export_to_photo_wall.size).not_to eq(0)
    end

    it "should have a button to export to photo wall" do
      render

      export_to_photo_wall = Hpricot(rendered).submit_for("Export Selected to Photo Wall")
      expect(export_to_photo_wall.size).not_to eq(0)
    end

    def random_child_summary(id = 'some_id')
      child = Child.create("age_is" => "Approx", "created_by" => "dave", "current_photo_key" => "photo-id")
      child.create_unique_id
      allow(child).to receive(:has_one_interviewer?).and_return(true)
      child
    end

    def time_now
      Clock.now.strftime("%d %B %Y at %H:%M (%Z)")
    end
  end
end
