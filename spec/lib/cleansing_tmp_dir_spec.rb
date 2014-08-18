require 'spec_helper'

describe CleansingTmpDir do
  it 'should cleanup every 30 minutes' do
    scheduler = double
    expect(scheduler).to receive(:every).with('30m').and_yield

    expect(CleansingTmpDir).to receive(:cleanup!).and_return(true)
    CleansingTmpDir.schedule scheduler
  end

  it 'should cleanup files older than 10 minutes' do
    CleansingTmpDir.stub :dir_name => 'test_dir'
    expect(Dir).to receive(:glob).with('test_dir/*').and_yield('test_file_1.zip').and_yield('test_file_2.xls')
    expect(File).to receive(:mtime).with('test_file_1.zip').and_return(9.minutes.ago)
    expect(File).to receive(:mtime).with('test_file_2.xls').and_return(11.minutes.ago)
    expect(File).to receive(:delete).with('test_file_2.xls')
    CleansingTmpDir.cleanup!
  end

  it 'should try to create directory' do
    CleansingTmpDir.stub :dir_name => 'test_dir'
    expect(FileUtils).to receive(:mkdir_p).with('test_dir').and_return(true)
    expect(CleansingTmpDir.dir).to eq('test_dir')
  end

  it 'should generate temporary file name' do
    CleansingTmpDir.stub :dir => 'test_dir'
    UUIDTools::UUID.stub :random_create => 'test_filename'
    expect(CleansingTmpDir.temp_file_name).to eq('test_dir/test_filename')
  end
end
