require 'spec_helper'

describe PublishFormSectionController do
  include LoggedIn

  it "should publish form section documents" do
    form_sections = [basic_enabled_form_section]
    FormSection.should_receive(:all_by_order).and_return(form_sections)
    get :form_sections
    response.body.should == form_sections.to_json
  end

  it "should not publish disabled form sections" do
    form_sections = [disabled_form_section]
    FormSection.should_receive(:all_by_order).and_return(form_sections)
    get :form_sections
    response.body.should == [].to_json
  end

  # Waiting for story #58 Enable / Disable fields to be played
  it "should only show fields on a form that are enabled"

  private

  def disabled_form_section
    form_section = basic_enabled_form_section
    form_section.enabled = false
    return form_section
  end

  def basic_enabled_form_section
    FormSection.new("name" =>"Basic details",
                    "enabled"=>true,
                    :description => "Basic information about a child",
                    :order=> 1, :unique_id=>"basic_details",
                    :editable => false,
                    :fields => basic_details_fields)
  end

  def basic_details_fields
    [
            Field.new("name" => "name", "type" => "text_field"),
            Field.new("name" => "gender", "type" => "radio_button", "option_strings" => ["Male", "Female"]),
    ]
  end

end