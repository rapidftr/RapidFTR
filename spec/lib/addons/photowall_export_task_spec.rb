require 'spec_helper'

module Addons
  describe PhotowallExportTask do
    before :each do
      PhotowallExportTask.stub! :enabled? => true
      @task = PhotowallExportTask.new
    end

    it 'should be an ExportTask addon' do
      RapidftrAddon::ExportTask.implementations.should include PhotowallExportTask
    end

    it 'should have proper addon_id' do
      RapidftrAddon::ExportTask.find_by_addon_id(:photowall).should == PhotowallExportTask
    end

    it 'should delegate to ExportGenerator' do
      children, generator = double, double
      ExportGenerator.should_receive(:new).with(children).and_return(generator)
      generator.should_receive(:to_photowall_pdf).and_return('dummy data')

      @task.generate_data(children).should == 'dummy data'
    end

    it 'should generate filename for one child' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([ child ]).should == 'test-id.pdf'
    end

    it 'should generate filename for multiple children' do
      child = build :child, :unique_identifier => "test-id"
      @task.generate_filename([child, child]).should == 'photowall.pdf'
    end
  end
end
