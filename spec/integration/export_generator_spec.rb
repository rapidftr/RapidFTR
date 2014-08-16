require 'spec_helper'

describe ExportGenerator, :type => :request do

  it "should generate a PDF file for a single child record" do
    child = build_child("jdoe", {
                          "name" => "Dave",
                          "age" => "28",
                          "last_known_location" => "London"})
    pdf_generator = ExportGenerator.new child
    pdf_generator.to_full_pdf
    pdf_generator.to_photowall_pdf
  end

  it "should generate a PDF file for multiple child records" do
    child_a = build_child "Bob"
    child_b = build_child "Gerald"
    pdf_generator = ExportGenerator.new [child_a, child_b]
    pdf_generator.to_full_pdf
    pdf_generator.to_photowall_pdf
  end

  describe "Suspect status" do
    before do
      @suspected_child = build_child "Suhas", :flag => true
      @unsuspected_child = build_child "Suhas", :flag => false
    end

    context "in PDF generation" do
      it "should be rendered when child is flagged as suspect" do
        generated_pdf = ExportGenerator.new(@suspected_child).to_full_pdf
        plain_text = ::PDF::Inspector::Text.analyze(generated_pdf)
        expect(plain_text.strings).to include "Flagged as Suspect Record"
      end

      it "should not be rendered when child is not flagged as suspect" do
        generated_pdf = ExportGenerator.new(@unsuspected_child).to_full_pdf
        plain_text = ::PDF::Inspector::Text.analyze(generated_pdf)
        expect(plain_text.strings).not_to include "Flagged as Suspect Record"
      end
    end

    context "in CSV generation" do
      it "should be rendered when child is flagged as suspect" do
        generated_csv = ExportGenerator.new(@suspected_child).to_csv.data
        rows = CSV.parse(generated_csv)
        expect(rows[0]).to include "Suspect status"
        suspect_status_colummn_index = rows[0].index("Suspect status")
        expect(rows[1][suspect_status_colummn_index]).to eq("Suspect")
      end

      it "should not be rendered when child is not flagged as suspect" do
        generated_csv = ExportGenerator.new(@unsuspected_child).to_csv.data
        rows = CSV.parse(generated_csv)
        expect(rows[0]).to include "Suspect status"
        suspect_status_colummn_index = rows[0].index("Suspect status")
        expect(rows[1][suspect_status_colummn_index]).to eq("")
      end
    end
  end

  describe "Reunification status" do
    before do
      @reunited_child = build_child "Bob", :reunited => true
      @not_reunited_child = build_child "Bob", :reunited => false
    end

    context "in PDF generation" do
      it "should be rendered when child is reunited" do
        generated_pdf = ExportGenerator.new(@reunited_child).to_full_pdf
        plain_text = ::PDF::Inspector::Text.analyze(generated_pdf)
        expect(plain_text.strings).to include "Reunited"
      end

      it "should not be rendered when child is not reunited" do
        generated_pdf = ExportGenerator.new(@not_reunited_child).to_full_pdf
        plain_text = ::PDF::Inspector::Text.analyze(generated_pdf)
        expect(plain_text.strings).not_to include "Reunited"
      end
    end

    context "in CSV generation" do
      it "should be rendered when child is reunited" do
        generated_csv = ExportGenerator.new(@reunited_child).to_csv.data
        rows = CSV.parse(generated_csv)
        expect(rows[0]).to include "Reunited status"
        suspect_status_colummn_index = rows[0].index("Reunited status")
        expect(rows[1][suspect_status_colummn_index]).to eq("Reunited")
      end

      it "should not be rendered when child is not reunited" do
        generated_csv = ExportGenerator.new(@not_reunited_child).to_csv.data
        rows = CSV.parse(generated_csv)
        expect(rows[0]).to include "Reunited status"
        reunited_status_colummn_index = rows[0].index("Reunited status")
        expect(rows[1][reunited_status_colummn_index]).to eq("")
      end
    end
  end

  describe "when a section is blank" do
    # before :all do
    #   form = FormSection.new(:name => "test_form", :order => 1 )
    #   form.save!
    # end

    # after :all do
    #   FormSection.all.each{ |form| form.destroy }
    # end

    # it "should not fail" do
    #   child = build_child("jdoe", {
    #       "name" => "Dave",
    #       "age" => "28",
    #       "last_known_location" => "London"})
    #   pdf_generator = ExportGenerator.new child
    #   subject.to_full_pdf
    #  end
  end

  private

  def build_child(created_by, options = {})
    user = User.new(:user_name => created_by)
    Child.new_with_user_name user, options
  end
end
