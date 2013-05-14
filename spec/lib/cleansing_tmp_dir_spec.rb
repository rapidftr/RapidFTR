require 'spec_helper'

describe CleansingTmpDir do
  it 'should cleanup every 30 minutes' do
    scheduler = double()
    scheduler.should_receive(:every).with("30m").and_yield()

    CleansingTmpDir.should_receive(:cleanup!).and_return(true)
    CleansingTmpDir.schedule scheduler
  end

  it 'should cleanup files older than 10 minutes' do
    CleansingTmpDir.stub! :dir_name => 'test_dir'
    Dir.should_receive(:glob).with('test_dir/*').and_yield("test_file_1.zip").and_yield("test_file_2.xls")
    File.should_receive(:mtime).with('test_file_1.zip').and_return(9.minutes.ago)
    File.should_receive(:mtime).with('test_file_2.xls').and_return(11.minutes.ago)
    File.should_receive(:delete).with('test_file_2.xls')
    CleansingTmpDir.cleanup!
  end

  it 'should try to create directory' do
    CleansingTmpDir.stub! :dir_name => 'test_dir'
    FileUtils.should_receive(:mkdir_p).with('test_dir').and_return(true)
    CleansingTmpDir.dir.should == 'test_dir'
  end

  it 'should generate temporary file name' do
    CleansingTmpDir.stub! :dir => 'test_dir'
    UUIDTools::UUID.stub! :timestamp_create => 'test_filename'
    CleansingTmpDir.temp_file_name.should == 'test_dir/test_filename'
  end
end