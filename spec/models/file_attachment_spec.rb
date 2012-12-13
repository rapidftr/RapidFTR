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
      FileAttachment.should_receive(:from_file).with(uploaded_audio, uploaded_audio.content_type, "prefix", "postfix", nil)
      FileAttachment.from_uploadable_file(uploaded_audio, "prefix", "postfix")
    end

  end

  describe ".from_file" do
    before(:each) do
      @file = stub!("File")
      @file.stub!(:read).and_return("Data")
    end

    it "should create an instance with a name from current date and default prefix" do
      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
      attachment = FileAttachment.from_file(@file, "")
      attachment.name.should == 'file-2010-01-17T140532'
    end

    it "should create an instance with a name from current date and prefix and postfix" do
      Clock.stub!(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
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

  describe '#resize' do
    before :each do
      @child = stub_model Child
      @data = mock()
      @attachment = FileAttachment.new "test", "image/jpg", @data, @child
    end

    it 'should create and save new thumbnail' do
      new_data = mock()
      StringIO.stub :new => new_data

      @child.stub! :has_attachment? => false
      @child.stub! :attach => false
      @child.stub! :save => false
      @attachment.stub! :resized_blob => new_data

      actual = @attachment.resize("160")
      actual.data.should == new_data
      actual.name.should == 'test_160'
      actual.content_type.should == 'image/jpg'
      actual.child.should == @child
    end

    it 'should return existing thumbnail' do
      media = mock()
      @child.should_receive(:has_attachment?).with('test_160').and_return(true)
      @child.should_receive(:media_for_key).with('test_160').and_return(media)
      @attachment.should_not_receive(:resized_blob)

      @attachment.resize("160").should == media
    end
  end

end
