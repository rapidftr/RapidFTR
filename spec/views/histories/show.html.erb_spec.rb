require 'spec_helper'

describe "histories/show.html.erb" do

  describe "child history" do


    before do
      FormSectionDefinition.stub!(:all_child_field_names).and_return(["age", "last_known_location", "current_photo_key"])
    end

    it "should render only the creation record when no histories yet" do
      assigns[:child] = Child.create(:last_known_location => "Haiti", :photo => uploadable_photo)
      render
      response.should have_tag("li", :count => 1)
      response.should have_tag("li", :text => /Record created by/)
    end

    it "should render photo change record when updating a photo" do
      child = Child.create(:last_known_location => "Haiti", :photo => uploadable_photo)

      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      assigns[:child] = Child.get(child.id)
      render

      response.should have_tag("li", :count => 2)
      response.should have_tag("li", :text => /Photo changed/)
    end

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

      response.should have_selector("li") do |elements|
        elements[0].should contain(/Age changed from 7 to 8/)
        elements[1].should contain(/Last known location changed from Haiti to Santiago/)
        elements[2].should contain(/Age changed from 6 to 7/)
        elements[3].should contain(/Record created by/)
      end
    end
  end
end