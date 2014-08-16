require 'spec_helper'

describe FieldsHelper, :type => :helper do

  before :each do
    @fields_helper = Object.new.extend FieldsHelper
  end

  it "should give back tuples of form unique id and display name" do
    form = build :form
    first_form = FormSection.new(:name => nil, :unique_id => "first_form", :form => form)
    second_form = FormSection.new(:name => "Third Form", :unique_id => "third_form", :form => form)
    third_form = FormSection.new(:name => "Middle Form", :unique_id => "middle_form", :form => form)
    allow(FormSection).to receive(:all_form_sections_for).with(form.name).and_return [first_form, second_form, third_form]

    expect(@fields_helper.form_sections_for_display(form)).to eq([[nil, "first_form"], ["Middle Form", "middle_form"], ["Third Form", "third_form"]])
  end

end
