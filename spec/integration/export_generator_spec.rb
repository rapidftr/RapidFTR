require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExportGenerator do

  it "should generate a PDF file for a single child record" do
    child = Child.new_with_user_name("jdoe", {
        "name" => "Dave",
        "age" => "28",
        "last_known_location" => "London"})
    pdf_generator = ExportGenerator.new child
    pdf_generator.to_full_pdf
  	pdf_generator.to_photowall_pdf
	end

	it "should generate a PDF file for multiple child records" do
		child_a = Child.new_with_user_name "Bob"
		child_b = Child.new_with_user_name "Gerald"
		pdf_generator = ExportGenerator.new [child_a, child_b]
		pdf_generator.to_full_pdf
		pdf_generator.to_photowall_pdf
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
			pdf_generator = ExportGenerator.new child
      subject.to_full_pdf
     end
  end
  
end
