require 'spec_helper'

describe "children/_summary_row.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "Yes")
  	assigns[:highlighted_fields] = []
		#the stuff you have to do when you don't start with something under test
		user = stub(User)
		user.stub!(:localize_date).and_return(:localized)
		assigns[:user] = user
		
	end

	it "should not have a photo tag when the child record has no photo" do
		render :locals => {:summary_row_counter=>1,  :summary_row => @child, :checkbox => :false}
		response.should_not have_tag("p.photo")
  end
  
end
