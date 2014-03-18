require 'spec_helper'

module Addons
  describe PdfExportTask do
    before :each do
      PdfExportTask.stub :enabled? => true
      @task = PdfExportTask.new
    end

    it 'should be an ExportTask addon' do
      RapidftrAddon::ExportTask.active.should include PdfExportTask
    end

    it 'should have proper id' do
      RapidftrAddon::ExportTask.find_by_id(:pdf).should == PdfExportTask
    end

    it 'should delegate to ExportGenerator' do
      children, generator = double, double
      ExportGenerator.should_receive(:new).with(children).and_return(generator)
      generator.should_receive(:to_full_pdf).and_return('dummy data')

      @task.generate_data(children).should == 'dummy data'
    end

    it 'should generate filename for one child' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([ child ]).should == 'test-id.pdf'
    end

    it 'should generate filename for multiple children' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([child, child]).should == 'full_data.pdf'
    end
  end
end
