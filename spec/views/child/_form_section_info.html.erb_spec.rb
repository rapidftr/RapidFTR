require 'spec_helper'

describe "children/_form_section_info.html.erb" do
    before { FormSection.all.each &:destroy }

    it "should show form section description and help text" do
      form_section = FormSection.create_new_custom "Basic Form",
                                                    "This is a description for basic form",
                                                    "Help text for basic form"
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info.html.erb', :locals => { :form_section => form_section }

      rendered.should be_include("form-section-description")
      rendered.should be_include("form-section-help-text")
    end

    it "should show form section description but no help text" do
      form_section = FormSection.create_new_custom "Basic Form","This is a description for basic form", nil
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info.html.erb', :locals => { :form_section => form_section }

      rendered.should be_include("form-section-description")
      rendered.should_not be_include("form-section-help-text")
    end

    it "should show help text but no form section description" do
      form_section = FormSection.create_new_custom "Basic Form", nil, "This is some help text"
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info.html.erb', :locals => { :form_section => form_section }

      rendered.should_not be_include("form-section-description")
      rendered.should be_include("form-section-help-text")
    end

    it "should show neither" do
      form_section = FormSection.create_new_custom "Basic Form", nil, nil
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info.html.erb', :locals => { :form_section => form_section }

      rendered.should_not be_include("form-section-description")
      rendered.should_not be_include("form-section-help-text")
    end

end
