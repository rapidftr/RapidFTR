require "spec_helper"

describe FormSectionDefinition do
  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSectionDefinition.new
      unique_id = "fred"
      FormSectionDefinition.stub(:first).with(:unique_id=>unique_id).and_return(expected)

      FormSectionDefinition.get_by_unique_id(unique_id).should == expected

    end
  end
end