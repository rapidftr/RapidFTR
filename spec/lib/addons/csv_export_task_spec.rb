require 'spec_helper'

module Addons
  describe CsvExportTask do
    before :each do
      CsvExportTask.stub :enabled? => true
      @task = CsvExportTask.new
    end

    it 'should be an ExportTask addon' do
      expect(RapidftrAddon::ExportTask.active).to include CsvExportTask
    end

    it 'should have proper id' do
      expect(RapidftrAddon::ExportTask.find_by_id(:csv)).to eq(CsvExportTask)
    end

    it 'should delegate to ExportGenerator' do
      children, generator, result = double, double, double
      expect(ExportGenerator).to receive(:new).with(children).and_return(generator)
      expect(generator).to receive(:to_csv).and_return(result)
      expect(result).to receive(:data).and_return('dummy data')

      expect(@task.generate_data(children)).to eq('dummy data')
    end

    it 'should generate filename for one child' do
      child = build :child, :unique_identifier => 'test-id'
      expect(@task.generate_filename([child])).to eq('test-id.csv')
    end

    it 'should generate filename for multiple children' do
      child = build :child, :unique_identifier => 'test-id'
      expect(@task.generate_filename([child, child])).to eq('full_data.csv')
    end
  end
end
