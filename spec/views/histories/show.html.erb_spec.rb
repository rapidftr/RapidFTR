require 'spec_helper'

describe "histories/show.html.erb" do

  describe "history of a child" do

    it "should render only the creation record when no histories yet" do
      assigns[:child] = Child.create(:last_known_location => "Haiti", :photo => uploadable_photo)
      render
      response.should have_tag("li", :count => 1)
      response.should have_tag("li", :text => /Record created by/)
    end    
  end
end