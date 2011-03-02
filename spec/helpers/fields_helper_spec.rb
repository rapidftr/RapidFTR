require 'spec_helper'

describe FieldsHelper do
   
   it "should give back tuples of form unique id and display name" do
     first_form = FormSection.new(:name => "First Form", :unique_id => "first_form")
     second_form = FormSection.new(:name => "Third Form", :unique_id => "third_form")
     third_form = FormSection.new(:name => "Middle Form", :unique_id => "middle_form")
     FormSection.stub(:all).and_return [first_form, second_form, third_form]
     
     fields_helper = Object.new
     fields_helper.extend(FieldsHelper)
     
     fields_helper.forms_for_display.should == [["First Form", "first_form"], ["Middle Form", "middle_form"], ["Third Form", "third_form"]]
   end
 end