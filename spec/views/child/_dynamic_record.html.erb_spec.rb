require 'spec_helper'

describe "children/_dynamic_record.html.erb" do

  describe "rendering the Child record"  do

    it "renders text fields" do

      render :locals => { :dynamic_record => {"name" => "Tom", "age" => "23", "origin" => "London"} }

      response.should contain("Name: Tom")
      response.should contain("Age: 23")
      response.should contain("Origin: London")
    end

    it "renders repeating text fields on a single line" do

      render :locals => { :dynamic_record => {"uncle_name" => ["Tim", "Mike", "Paul"]} }

      response.should contain("Uncle names: Tim, Mike, Paul")
    end

    

  end

end


