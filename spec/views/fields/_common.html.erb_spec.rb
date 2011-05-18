require 'spec_helper'
require 'hpricot'
require 'support/hpricot_search'
include HpricotSearch

describe "fields/_common.html.erb" do
  describe "rendering an uneditable field" do 

    it "should not have the move to another form dropdown when uneditable field" do
      move_to_another_form_dropdown_for_field_when_editable_is(false)
      Hpricot(response.body).at("#destination_form_id").should == nil
    end
    
    it "should have the move to another form dropdown when editable field" do
      move_to_another_form_dropdown_for_field_when_editable_is(true)
      Hpricot(response.body).at("#destination_form_id").should_not == nil
    end
  end

  def move_to_another_form_dropdown_for_field_when_editable_is(editable)
    field = Field.new(:name => "other", :type => "text_field", :editable => editable)
    assigns[:form_section] = FormSection.new(:fields => [field], :unique_id => "basic details")
    assigns[:field] = field
    # using FormBuilder within ActionView::Base::FormHelper to mimic passing form to view 
    render :locals => {:f => ActionView::Base.default_form_builder.new(field.name, field, self, nil, nil)}      
  end
end
