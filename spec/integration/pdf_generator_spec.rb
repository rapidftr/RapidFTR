require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PdfGenerator do

  it "should_generate_a_pdf" do
    child = Child.new_with_user_name("jdoe", {
        "name" => "Dave",
        "age" => "28",
        "last_known_location" => "London"})
    
    subject.children_info [child]
  end

  describe "when a section is blank" do
    before :all do  
      form = FormSection.new(:name => "test_form", :order => 1 )
      form.save!
    end

    after :all do
      FormSection.all.each{ |form| form.destroy }
    end

    it "should not fail" do
      child = Child.new_with_user_name("jdoe", {
          "name" => "Dave",
          "age" => "28",
          "last_known_location" => "London"})

      subject.children_info [child]
     end
  end
  
end