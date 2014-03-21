require "spec_helper"

def mock_suggestedfield(stubs={})
  stubs.reverse_merge!(:is_used= =>false, :save=>true)
  @mock_formsection ||= mock_model(SuggestedField, stubs)
end


describe SuggestedField do
  describe "get_by_unique_id"  do
    it "should locate by unique_id" do
      expected = SuggestedField.new
      unique_id = "fred"
      SuggestedField.stub(:by_unique_id).with(:key=>unique_id).and_return([expected])
      SuggestedField.get_by_unique_id(unique_id).should == expected
      # line by line same as FormSection.get_by_   also should it just use get?
    end

  end
  describe "mark_as_used" do
    before :each do
      @suggested_field_id = "the_field"
      @suggested_field =  mock_suggestedfield()
      SuggestedField.stub(:get_by_unique_id).with(@suggested_field_id).and_return(@suggested_field)
    end
    it "should set is_used to true" do
      @suggested_field.should_receive(:is_used=).with(true)
      SuggestedField.mark_as_used(@suggested_field_id)
    end
    it "should save the suggested field" do
      @suggested_field.should_receive(:save)
      SuggestedField.mark_as_used(@suggested_field_id)
    end
  end
  describe "all_unused" do
    it "only return the suggested fields that have not been used" do
      suggested_fields = [SuggestedField.new, SuggestedField.new]
      SuggestedField.stub(:by_is_used).with(:key=>false).and_return(suggested_fields)
      SuggestedField.all_unused().should == suggested_fields  
    end
  end
end