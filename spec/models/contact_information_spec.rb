require 'spec_helper'
describe ContactInformation do
  describe "get_by_id" do
    it "Should create the contact information if it does not exist" do
      contact_info = ContactInformation.get_by_id "ThisIsATest"
      contact_info.should_not be_nil
      ContactInformation.all[0].id.should == "ThisIsATest"
    end
  end
end