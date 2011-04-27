require 'spec_helper'
require 'support/couchdb_client_helper'

describe Child do
  include CouchdbClientHelper
  it "should save a child in the database" do
    photo = uploadable_photo
    child = Child.new_with_user_name("jdoe", {
        "name" => "Dave",
        "age" => "28",
        "last_known_location" => "London",
        "photo" => photo})
    child.save.should be_true, display_child_errors(child.errors)

    data = get_object(:child, child.id)

    data['name'].should == "Dave"
    data['age'].should == "28"
    data['last_known_location'].should == "London"
    data['_attachments'].should_not be_empty
    data['_attachments'][data['childs_photo']]['content_type'].should == photo.content_type
  end

  it "should load an existing child record from the database" do
    child_fixture = Child.new_with_user_name("jdoe", {
        "name" => "Paul",
        "age" => "10",
        "last_known_location" => "New York"})
    child_id = post_object(:child, child_fixture)

    child = Child.get(child_id)

    child['name'].should == "Paul"
    child['age'].should == "10"
    child['last_known_location'].should == "New York"
  end

  it "should persist multiple photo attachments" do
    Time.stub!(:now).and_return Time.parse("Jan 20 2010 12:04:15")
    child = Child.create('last_known_location' => "New York")
    child.set_photo('childs_photo', uploadable_photo_jeff)
    child.save

    Time.stub!(:now).and_return Time.parse("Feb 20 2010 12:04:15")
    created_child = Child.get(child.id)
    created_child.set_photo('childs_photo', uploadable_photo)
    created_child.save

    updated_child = Child.get(child.id)
    verify_attachment(updated_child.media_for_id('childs_photo-2010-01-20T120415'), uploadable_photo_jeff)
    verify_attachment(updated_child.media_for_id('childs_photo-2010-02-20T120415'), uploadable_photo)
  end
end

def verify_attachment(attachment, uploadable_file)
  attachment.content_type.should == uploadable_file.content_type
  attachment.data.read.should == uploadable_file.read
end

def display_child_errors(errors)
  errors.values.each {|value| puts value}
end
