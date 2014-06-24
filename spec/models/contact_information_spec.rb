require 'spec_helper'
describe ContactInformation do
  before :each do
    ContactInformation.all.each {|contact_info| contact_info.destroy}
  end
  describe "get_or_create" do
    it "Should create the contact information if it does not exist" do
      contact_info = ContactInformation.get_or_create "ThisIsATest"
      contact_info.should_not be_nil
      contact_info.id.should == "ThisIsATest"
      ContactInformation.all.all[0].id.should == "ThisIsATest"
    end
  end
  describe "get_by_id" do
    it "Should return a contact info by id" do
      expected = ContactInformation.new({:id=>"ThisIsATest"})
      expected.save!
      contact_info = ContactInformation.get_by_id "ThisIsATest"
      contact_info.should == expected
    end
    it "should raise if contact info doesn't exist" do
      lambda {
               ContactInformation.get_by_id "ThisIsATest"
            }.should raise_error( ErrorResponse )
    end
  end
end
