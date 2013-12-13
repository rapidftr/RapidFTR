require 'spec_helper'

describe "children/_form_section_info.html.erb" do
    before { FormSection.all.each &:destroy }

    it "should show form section description and help text" do
      form_section = FormSection.new_with_order({:new => "Basic Form",
                                                 :description => "This is a description for basic form",
                                                 :help_text => "Help text for basic form"})
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info', :locals => { :form_section => form_section }, :formats => [:html], :handlers => [:erb]

      rendered.should be_include("form-section-description")
      rendered.should be_include("form-section-help-text")
    end

    it "should show form section description but no help text" do
      form_section = FormSection.new_with_order :name => "Basic Form", :description => "This is a description for basic form", :help_text => nil
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info', :locals => { :form_section => form_section }, :formats => [:html], :handlers => [:erb]

      rendered.should be_include("form-section-description")
      rendered.should_not be_include("form-section-help-text")
    end

    it "should show help text but no form section description" do
      form_section = FormSection.new_with_order :name => "Basic Form", :description => nil, :help_text => "This is some help text"
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info', :locals => { :form_section => form_section }, :formats => [:html], :handlers => [:erb]

      rendered.should_not be_include("form-section-description")
      rendered.should be_include("form-section-help-text")
    end

    it "should show neither" do
      form_section = FormSection.new_with_order :name => "Basic Form", :description => nil, :help_text => nil
      assigns[:form_sections] = [form_section]

      render :partial => 'children/form_section_info', :locals => { :form_section => form_section }, :formats => [:html], :handlers => [:erb]

      rendered.should_not be_include("form-section-description")
      rendered.should_not be_include("form-section-help-text")
    end

end
