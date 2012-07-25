require "spec_helper"

describe "FieldOption" do

  describe "HTML tag generation" do

    before :each do
      @field_name = "is_age_exact"
      @option_name = "Approximate"
      @field_option = FieldOption.new @field_name, @option_name

    end
    it "converts field and option names to a HTML tag names" do
      @field_option.tag_name_attribute.should == "child[#{@field_name}][#{@option_name}]"
    end

    it "converts field and option names to a HTML tag IDs" do
      @field_option.tag_id.should == "child_#{@field_name}_#{@option_name.downcase}"
    end

  end

  describe "FieldOption creation" do

    it "has a factory method for creating all FieldOption objects for a given Field" do
      field_name = "gender"
      options = ["male", "female"]

      field_options = FieldOption.create_field_options(field_name, options)

      field_options[0].tag_name_attribute.should == "child[gender][male]"
      field_options[1].tag_name_attribute.should == "child[gender][female]"
    end

  end

end

