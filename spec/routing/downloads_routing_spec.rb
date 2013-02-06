require 'spec_helper'

describe ChildrenController do
  describe "routing" do
    it 'handles a multi-child export request' do
      { :post => 'downloads/children_data.pdf' }.should route_to(:format =>"pdf", :controller => 'downloads', :action => 'children_data' )
    end

    it 'recognizes and generates data for child' do
      {:post => 'downloads/child_data.pdf'}.should route_to(:format =>"pdf", :controller => 'downloads', :action => 'child_data')
    end

    it 'recognizes and generates record for children' do
      {:post => 'downloads/children_record.pdf'}.should route_to(:format =>"pdf", :controller => 'downloads', :action => 'children_record')
    end

    it 'recognizes and generates photo for child' do
      {:post => 'downloads/child_photo.pdf'}.should route_to(:format =>"pdf", :controller => 'downloads', :action => 'child_photo')
    end
  end
end

