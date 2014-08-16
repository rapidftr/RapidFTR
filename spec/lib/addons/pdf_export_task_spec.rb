require 'spec_helper'

module Addons
  describe PdfExportTask do
    before :each do
      PdfExportTask.stub :enabled? => true
      @task = PdfExportTask.new
    end

    it 'should be an ExportTask addon' do
      expect(RapidftrAddon::ExportTask.active).to include PdfExportTask
    end

    it 'should have proper id' do
      expect(RapidftrAddon::ExportTask.find_by_id(:pdf)).to eq(PdfExportTask)
    end

    it 'should delegate to ExportGenerator' do
      children, generator = double, double
      expect(ExportGenerator).to receive(:new).with(children).and_return(generator)
      expect(generator).to receive(:to_full_pdf).and_return('dummy data')

      expect(@task.generate_data(children)).to eq('dummy data')
    end

    it 'should generate filename for one child' do
      child = build :child, :unique_identifier => "test-id"
      expect(@task.generate_filename([child])).to eq('test-id.pdf')
    end

    it 'should generate filename for multiple children' do
      child = build :child, :unique_identifier => "test-id"
      expect(@task.generate_filename([child, child])).to eq('full_data.pdf')
    end
  end
end
