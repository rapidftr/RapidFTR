require 'spec_helper'

describe Enquiry do

  describe '#update_from_properties' do
    it "should update the enquiry" do
      enquiry = Enquiry.new({:reporter_name => 'Vivek', :place => 'Kampala'})
      properties = {:reporter_name => 'DJ', :place => 'Kampala'}

      enquiry.update_from(properties)

      enquiry.reporter_name.should == 'DJ'
      enquiry['place'].should == 'Kampala'
    end
  end
end