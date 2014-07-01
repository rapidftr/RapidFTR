require 'spec_helper'

module Addons
  describe CsvExportTask do
    before :each do
      CsvExportTask.stub :enabled? => true
      @task = CsvExportTask.new
    end

    it 'should be an ExportTask addon' do
      RapidftrAddon::ExportTask.active.should include CsvExportTask
    end

    it 'should have proper id' do
      RapidftrAddon::ExportTask.find_by_id(:csv).should == CsvExportTask
    end

    it 'should delegate to ExportGenerator' do
      children, generator, result = double, double, double
      ExportGenerator.should_receive(:new).with(children).and_return(generator)
      generator.should_receive(:to_csv).and_return(result)
      result.should_receive(:data).and_return('dummy data')

      @task.generate_data(children).should == 'dummy data'
    end

    it 'should generate filename for one child' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([ child ]).should == 'test-id.csv'
    end

    it 'should generate filename for multiple children' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([child, child]).should == 'full_data.csv'
    end
  end
end
