require 'spec_helper'

describe "histories/show.html.erb" do

  describe "child history" do

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
  end
end