require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

describe "fields/_common.html.erb" do
  describe "rendering an uneditable field" do 
    before :each do
      @fields =  [Field.new(:name => "other", :type => "text_field", :editable => false)] 
      form = FormSection.new(:fields => @fields, :unique_id => "basic details")
      @field2 = form.fields.fetch(0)

      assigns[:field] = @field2
      assigns[:form_section] = form
      render :locals => {:f => ActionView::Base.default_form_builder.new(@field2.name, @field2, self, nil, nil)}
      @searchable_response = Hpricot(response.body)
    end
    it "should not have the move to another form dropdown" do
      @searchable_response.at("#destination_form_id").should == nil
    end
  end
  describe "rendering an editable field" do 
    before :each do
      @fields =  [Field.new(:name => "other2", :type => "text_field", :editable => true)] 
      form = FormSection.new(:fields => @fields, :unique_id => "basic details2")
      @field2 = form.fields.fetch(0)

      assigns[:field] = @field2
      assigns[:form_section] = form
      render :locals => {:f => ActionView::Base.default_form_builder.new(@field2.name, @field2, self, nil, nil)}
      @searchable_response = Hpricot(response.body)
    end
    it "should have the move to another form dropdown" do
      @searchable_response.at("#destination_form_id").should_not == nil
    end
  end
end
