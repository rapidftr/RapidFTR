require "spec_helper"

describe "FileAttachment" do

  it "should create an instance with a name from current date and default prefix" do
    current_time = Time.parse("Jan 17 2010 14:05")
    Time.stub!(:now).and_return current_time
    attachment = FileAttachment.from_uploadable_file(uploadable_photo)
    attachment.name.should == 'file-17-01-2010-1405'
  end

  it "should create an instance with a name from current date and prefix" do
    current_time = Time.parse("Jan 17 2010 14:05")
    Time.stub!(:now).and_return current_time
    attachment = FileAttachment.from_uploadable_file(uploadable_photo, "test")
    attachment.name.should == 'test-17-01-2010-1405'
  end

  it "should create an instance with content type from given file" do
    attachment = FileAttachment.from_uploadable_file(uploadable_photo)
    attachment.content_type.should == 'image/jpg'
  end

  it "should create an instance with data from given file" do
    attachment = FileAttachment.from_uploadable_file(uploadable_photo)
    attachment.data.read.should == File.read(uploadable_photo.original_path)
  end
end