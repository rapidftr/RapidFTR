require 'spec_helper'

describe AttachmentsController do
  
  before do
    fake_login
  end
  
  it "should have restful route for GET" do
    assert_routing( {:method => 'get', :path => '/children/1/attachments/3'}, 
                    {:controller => "attachments", :action => "show", :child_id => "1", :id => "3"})
  end

  it "should return correct response corresponding to created photo" do
    Clock.stub!(:now).and_return(Time.parse("Jan 20 2010 12:04:15"))
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)
    
    get :show, :child_id => child.id, :id => child.primary_photo.name

    response.content_type.should == uploadable_photo_jeff.content_type
    response.body.should == uploadable_photo_jeff.read
  end
  
  it "should return correct photo content type that is older than the current one" do
    Clock.stub!(:now).and_return(Time.parse("Jan 20 2010 12:04:24"))
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    Clock.stub!(:now).and_return(Time.parse("Feb 20 2010 12:04"))
    Child.get(child.id).update_attributes :photo => uploadable_photo

    get :show, :child_id => child.id, :id => child.primary_photo.name

    response.content_type.should == uploadable_photo_jeff.content_type
    response.body.should == uploadable_photo_jeff.read
  end
  
  it "should return correct photo size that is older than the current one" do
    Clock.stub!(:now).and_return(Time.parse("Jan 20 2010 12:04:24"))
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    Clock.stub!(:now).and_return(Time.parse("Feb 20 2010 12:04"))
    Child.get(child.id).update_attributes :photo => uploadable_photo

    get :show, :child_id => child.id, :id => child.primary_photo.name

    response.body.size.should == uploadable_photo_jeff.read.size
  end
end
