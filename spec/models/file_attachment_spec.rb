require 'spec_helper'

describe 'FileAttachment', :type => :model do

  describe '.from_uploadable_file' do
    it 'should extract content type from uploaded_file' do
      uploaded_file = uploadable_audio
      expect(uploaded_file).to receive(:content_type)
      FileAttachment.from_uploadable_file(uploaded_file)
    end

    it 'should call .from_file with all parameters and content_type extracted from uploaded_file' do
      uploaded_audio = uploadable_audio
      expect(FileAttachment).to receive(:from_file).with(uploaded_audio, uploaded_audio.content_type, 'prefix', 'postfix', nil)
      FileAttachment.from_uploadable_file(uploaded_audio, 'prefix', 'postfix')
    end

  end

  describe '.from_file' do
    before(:each) do
      @file = double('File')
      allow(File).to receive(:binread).with(@file).and_return('Data')
    end

    it 'should create an instance with a name from current date and default prefix' do
      allow(Clock).to receive(:now).and_return(Time.parse('Jan 17 2010 14:05:32'))
      attachment = FileAttachment.from_file(@file, '')
      expect(attachment.name).to eq('file-2010-01-17T140532')
    end

    it 'should create an instance with a name from current date and prefix and postfix' do
      allow(Clock).to receive(:now).and_return(Time.parse('Jan 17 2010 14:05:32'))
      attachment = FileAttachment.from_file(@file, '', 'pre', 'post')
      expect(attachment.name).to eq('pre-2010-01-17T140532-post')
    end

    it 'should create an instance with content type from given file' do
      attachment = FileAttachment.from_file(@file, 'image/jpg')
      expect(attachment.content_type).to eq('image/jpg')
    end

    it 'should create an instance with data from given file' do
      allow(File).to receive(:binread).with(@file).and_return('file_contents')
      attachment = FileAttachment.from_file(@file, '')
      expect(attachment.data.read).to eq('file_contents')
    end
  end

  describe '#resize' do
    before :each do
      @child = stub_model Child
      @data = double
      @attachment = FileAttachment.new 'test', 'image/jpg', @data, @child
    end

    it 'should create and save new thumbnail' do
      new_data = double
      StringIO.stub :new => new_data

      expect(@child).to receive(:has_attachment?).with('test_160').and_return(false)
      expect(@child).to receive(:attach).and_return(false)
      expect(@child).to receive(:save).and_return(false)
      expect(@attachment).to receive(:resized_blob).and_return(new_data)

      actual = @attachment.resize('160')
      expect(actual.data).to eq(new_data)
      expect(actual.name).to eq('test_160')
      expect(actual.content_type).to eq('image/jpg')
      expect(actual.child).to eq(@child)
    end

    it 'should return existing thumbnail' do
      media = double
      expect(@child).to receive(:has_attachment?).with('test_160').and_return(true)
      expect(@child).to receive(:media_for_key).with('test_160').and_return(media)
      expect(@attachment).not_to receive(:resized_blob)

      expect(@attachment.resize('160')).to eq(media)
    end
  end

end
