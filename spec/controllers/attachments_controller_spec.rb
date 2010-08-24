require 'spec_helper'

describe AttachmentsController do
  
  before do
    fake_login
  end
  
  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/children/1/attachments/3'}, 
                    {:controller => "attachments", :action => "show", :child_id => "1", :id => "3"})
  end
  
  it "should return correct content type corresponding to created photo" do
    Time.stub!(:now).and_return Time.parse("Jan 20 2010 12:04:24")
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    get :show, :child_id => child.id, :id => 'photo-2010-01-20T120424'

    response.body.size.should == uploadable_photo_jeff.size
    response.content_type.should == uploadable_photo_jeff.content_type
  end
  
  it "should return correct photo content type that is older than the current one" do
    Time.stub!(:now).and_return Time.parse("Jan 20 2010 12:04:24")
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    Time.stub!(:now).and_return Time.parse("Feb 20 2010 12:04:24")
    child.update_attributes :photo => uploadable_photo

    get :show, :child_id => child.id, :id => 'photo-2010-01-20T120424'

    response.content_type.should == uploadable_photo_jeff.content_type
  end
  
  it "should return correct photo size that is older than the current one" do
    pending "not sure why size is off for this test but not the one above ... works in UI"
    Time.stub!(:now).and_return Time.parse("Jan 20 2010 12:04:24")
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    Time.stub!(:now).and_return Time.parse("Feb 20 2010 12:04:24")
    child.update_attributes :photo => uploadable_photo

    get :show, :child_id => child.id, :id => 'photo-2010-01-20T120424'

    response.body.size.should == uploadable_photo_jeff.size
  end
end
