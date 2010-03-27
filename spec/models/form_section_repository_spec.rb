require "spec_helper"

describe "form section repository" do

  it "should return a form section for each form section definition" do

    sectiondef1= FormSectionDefinition.new
    sectiondef2 = FormSectionDefinition.new

    FormSectionDefinition.stub!(:all).and_return([sectiondef1,sectiondef2])

    sections = FormSectionRepository.all
    sections[0].class.should == FormSection
    sections.length.should == 2

  end

  it "should return a form section with the same name as each form section definition"  do
    sectiondef = FormSectionDefinition.new
    sectiondef.name = "foo";

    FormSectionDefinition.stub!(:all).and_return([sectiondef])

    sections = FormSectionRepository.all
    sections[0].section_name.should == "foo"

  end

end