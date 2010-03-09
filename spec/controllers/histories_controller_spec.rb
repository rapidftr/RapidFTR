require 'spec_helper'

describe HistoriesController do
  
  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/children/1/history'}, 
                    {:controller => "histories", :action => "show", :child_id => "1"})
  end
  
  it "should have created_by user name for initial log creation" do
    child = Child.new_with_user_name("some_user", :last_known_location => 'London')
    child.photo = uploadable_photo
    child.save!
    get :show, :child_id => child.id
    assert_equal "some_user", assigns(:child)['created_by']
  end
end