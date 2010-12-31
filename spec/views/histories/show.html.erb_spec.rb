require 'spec_helper'

describe "histories/show.html.erb" do

  describe "child history" do


    before do
      FormSection.stub!(:all_child_field_names).and_return(["age", "last_known_location", "current_photo_key"])
    end
    describe "rendering history for a newly created record" do
      it "should render only the creation record" do
        assigns[:child] = Child.create(:last_known_location => "Haiti", :photo => uploadable_photo)
        render
      	response.should have_selector(".history-details li", :count => 1)
      	response.should have_selector(".history-details li") do |item|
      		item.text.should match(/Record created by/)
      	end
      end
    end
    describe "rendering changes to photos" do
      it "should render photo change record when updating a photo" do
        child = Child.create(:last_known_location => "Haiti", :photo => uploadable_photo)

        updated_at_time = Time.parse("Feb 20 2010 12:04")
        Time.stub!(:now).and_return updated_at_time
        child.update_attributes :photo => uploadable_photo_jeff

        assigns[:child] = Child.get(child.id)
        render

      	response.should have_selector(".history-details li", :count => 2)
      	response.should have_selector(".history-details li") do |item|
      		item.text.should match(/Photo changed/)
      	end 
      end
    end
    describe "rendering changes to audio" do
      it "should render audio change record with links when updating a sound file" do
        child = Child.new
        child['histories'] =[ {
                           "changes" => {
                               "recorded_audio" => {
                                   "from" => "first audio file",
                                   "to" => "second audio file"
                               }
                           },
                           "user_name" => "rapidftr",
                           "datetime" => "31/12/2010 20:55"
        }]
        
        assigns[:child] = child
        render

      	response.should have_selector(".history-details li", :count => 2)
      	response.should have_selector(".history-details li") do |item|
      		item.text.should match(/Audio changed from FOO/)
      	end 
      end
    end
    describe "rendering several history entries" do
      it "should order history log from most recent change to oldest change" do
        child = Child.create(:age => "6", :last_known_location => "Haiti", :photo => uploadable_photo)

        child = Child.get(child.id)
        child['last_updated_at'] = "20/02/2010 12:04"
        child['age'] = '7'
        child.save!

        child = Child.get(child.id)
        child['last_updated_at'] = "20/02/2010 13:04"
        child['last_known_location'] = 'Santiago'
        child.save!

        child = Child.get(child.id)
        child['last_updated_at'] = "20/02/2011 12:04"
        child['age'] = '8'
        child.save!

        assigns[:child] = Child.get(child.id)
        render

        response.should have_selector(".history-details li") do |elements|
          elements[0].should contain(/Age changed from 7 to 8/)
          elements[1].should contain(/Last known location changed from Haiti to Santiago/)
          elements[2].should contain(/Age changed from 6 to 7/)
          elements[3].should contain(/Record created by/)
        end
      end
    end
  end
end