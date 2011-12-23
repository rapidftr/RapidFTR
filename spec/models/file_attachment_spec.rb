require "spec_helper"

describe "FileAttachment" do

  describe ".from_uploadable_file" do
    it "should extract content type from uploaded_file" do
      uploaded_file = uploadable_audio
      uploaded_file.should_receive(:content_type)
      FileAttachment.from_uploadable_file(uploaded_file);

    end

    it "should call .from_file with all parameters and content_type extracted from uploaded_file" do
      uploaded_audio = uploadable_audio
      FileAttachment.should_receive(:from_file).with(uploaded_audio, uploaded_audio.content_type, "prefix", "postfix")
      FileAttachment.from_uploadable_file(uploaded_audio, "prefix", "postfix")
    end

  end

  describe ".from_file" do
    before(:each) do
      @file = stub!("File")
      @file.stub!(:read).and_return("Data")
    end

    it "should create an instance with a name from current date and default prefix" do
      current_time = Time.parse("Jan 17 2010 14:05:32")
      Clock.fake_time_now = current_time
      attachment = FileAttachment.from_file(@file, "")
      attachment.name.should == 'file-2010-01-17T140532'
    end

    it "should create an instance with a name from current date and prefix and postfix" do
      current_time = Time.parse("Jan 17 2010 14:05:32")
      Clock.fake_time_now = current_time
      attachment = FileAttachment.from_file(@file, "", "pre", "post")
      attachment.name.should == 'pre-2010-01-17T140532-post'
    end

    it "should create an instance with content type from given file" do
      attachment = FileAttachment.from_file(@file, 'image/jpg')
      attachment.content_type.should == 'image/jpg'
    end

    it "should create an instance with data from given file" do
      @file.should_receive(:read).and_return('file_contents')
      attachment = FileAttachment.from_file(@file, '')
      attachment.data.read.should == 'file_contents'
    end

  end

end
