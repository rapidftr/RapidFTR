require 'spec_helper'

describe Child do

  describe "record_as_hash" do

    it "returns the Child record structure represented as a Hash" do
      child = Child.new
      child.name = "Tom Elkin"
      child.age = "27"
      child.origin = "London"

      child.record_as_hash.should == {"name" => "Tom Elkin", "age" => "27", "origin" => "London"}
    end

    it "returns the Child record content in a Form object" do
      child = Child.new
      child.age = "27"
      child.origin = "London"
      child.name = "Tom"

      form = child.as_form

      form.keys.should == ["name", "age", "origin"]
    end
  end
end
