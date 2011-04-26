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
    data['_attachments'][data['current_photo_key']]['content_type'].should == photo.content_type
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
    child = Child.create('last_known_location' => "New York", 'photo' => uploadable_photo_jeff)

    created_child = Child.get(child.id)
    Time.stub!(:now).and_return Time.parse("Feb 20 2010 12:04:15")

    created_child.update_attributes :photo => uploadable_photo
    
    updated_child = Child.get(child.id)
    photo_keys = updated_child['photo_keys']
    verify_attachment(updated_child.media_for_key(photo_keys.first), uploadable_photo_jeff)
    verify_attachment(updated_child.media_for_key(photo_keys.last), uploadable_photo)
  end
end

def verify_attachment(attachment, uploadable_file)
  attachment.content_type.should == uploadable_file.content_type
  attachment.data.read.should == uploadable_file.read
end

def display_child_errors(errors)
  errors.values.each {|value| puts value}
end
