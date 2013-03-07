require 'spec_helper'

describe CleanupEncryptedFiles do
  it 'should cleanup every 30 minutes' do
    scheduler = double()
    scheduler.should_receive(:every).with("30m").and_yield()

    CleanupEncryptedFiles.should_receive(:cleanup!).and_return(true)
    CleanupEncryptedFiles.schedule scheduler
  end

  it 'should cleanup files older than 10 minutes' do
    CleanupEncryptedFiles.stub! :dir_name => 'test_dir'
    Dir.should_receive(:glob).with('test_dir/*.zip').and_yield("test_file_1.zip").and_yield("test_file_2.zip")
    File.should_receive(:mtime).with('test_file_1.zip').and_return(9.minutes.ago)
    File.should_receive(:mtime).with('test_file_2.zip').and_return(11.minutes.ago)
    File.should_receive(:delete).with('test_file_2.zip')
    CleanupEncryptedFiles.cleanup!
  end
end
