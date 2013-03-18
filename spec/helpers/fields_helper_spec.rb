require 'spec_helper'

describe FieldsHelper do

  before :each do
    @fields_helper = Object.new.extend FieldsHelper
  end

   it "should give back tuples of form unique id and display name" do
     first_form = FormSection.new(:name => nil, :unique_id => "first_form")
     second_form = FormSection.new(:name => "Third Form", :unique_id => "third_form")
     third_form = FormSection.new(:name => "Middle Form", :unique_id => "middle_form")
     FormSection.stub(:all).and_return [first_form, second_form, third_form]

     @fields_helper.forms_for_display.should == [[nil, "first_form"], ["Middle Form", "middle_form"], ["Third Form", "third_form"]]
   end

  describe "option_fields" do
    it "should return empty array when suggestions is nil" do
      suggested_field = double(:field => double(:option_strings => nil))
      @fields_helper.option_fields_for(nil, suggested_field).should be_empty
    end

    it "should return empty array when suggestions is empty" do
      suggested_field = double(:field => double(:option_strings => []))
      @fields_helper.option_fields_for(nil, suggested_field).should be_empty
    end

    it "should return array of hidden fields for array of suggestions" do
      form = double("form helper")
      form.should_receive(:hidden_field).with("option_strings_text", hash_including(:multiple => true, :id => "option_string_1", :value => "1\n")).once.and_return("X")
      form.should_receive(:hidden_field).with("option_strings_text", hash_including(:multiple => true, :id => "option_string_2", :value => "2\n")).once.and_return("Y")

      suggested_field = double(:field => double(:option_strings => ["1", "2"]))
      option_fields = @fields_helper.option_fields_for(form, suggested_field)
      option_fields.should == ["X", "Y"]
    end
  end

end
