require 'spec_helper'

class Schema;
end

describe "children/show.html.erb" do

  describe "displaying a child's details"  do

    before do
      params[:id] = "1234"
      assigns[:child] = Child.new({
              "_id" => "d7ab411b5b8964b0ac178f2bc5b9b5b9",
              "basic_details" => {
                      "name" => "Adrian",
                      "supplementary_field" => "Supplementary field value",
                      "extra_field" => "Extra field value"
              }})
    end

    it "displays the Child's photo" do
      pending
    end

    it "renders all fields found on the ChildView" do

      child_view = ChildView.new
      child_view.unique_id='georgelon12345' 
      child_view.add_field Field.new("age", Field::TEXT_FIELD, [], "27")
      child_view.add_field Field.new("gender", Field::RADIO_BUTTON, ["male", "female"], "male")
      child_view.add_field Field.new("date_of_separation", Field::SELECT_BOX, ["1-2 weeks ago", "More than"], "1-2 weeks ago")


      assigns[:child_view] = child_view

      render

      response.should have_selector("dt") do |fields|
        fields[0].should contain("Unique Id")
        fields[1].should contain("Age")
        fields[2].should contain("Gender")
        fields[3].should contain("Date of separation")
      end
      
      response.should have_selector("dd") do |fields|
        fields[0].should contain("georgelon12345")
        fields[1].should contain("27")
        fields[2].should contain("male")
        fields[3].should contain("1-2 weeks ago")
      end
    end

    it "renders repeating text fields on a single line" do

      pending

      render :locals => { :form => {"uncle_name" => ["Tim", "Mike", "Paul"]} }

      response.should contain("Uncle names: Tim, Mike, Paul")
    end

  end

end
