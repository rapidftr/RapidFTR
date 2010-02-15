require 'spec_helper'

describe "children/_form_show.html.erb" do

  describe "rendering the Child record"  do

    it "renders text fields" do

      render :locals => { :form => Form.new({"name" => "Tom", "age" => "23", "origin" => "London"}) }

      response.should contain("Name: Tom")
      response.should contain("Age: 23")
      response.should contain("Origin: London")
    end

    it "renders repeating text fields on a single line" do

      render :locals => { :form => {"uncle_name" => ["Tim", "Mike", "Paul"]} }

      response.should contain("Uncle names: Tim, Mike, Paul")
    end

    it "renders fields in the order they were defined on the Schema" do
      Schema.stub(:keys_in_order).and_return(['c', 'a', 'b'])

      render :locals => { :form => Form.new({'a' => 'Apple', 'b' => 'Banana', 'c' => 'Cat'})}

      response.should have_xpath("//div[@class='field'][1]") do |first_field|
        first_field.should contain "Cat"
      end
      response.should have_xpath("//div[@class='field'][2]") do |second_field|
        second_field.should contain "Apple"
      end

      end
    end

  end


