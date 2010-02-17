require 'spec_helper'

class Schema;
end

describe "children/show.html.erb" do

  describe "rendering a Child record"  do

    before do
      params[:id] = "1234"
    end

    it "displays the Child's photo" do
      pending
    end

    it "it displays all fields found on the record, in the order the appear on the Schema" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "basic_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "name",
                                      "type" => "text_field"
                              },
                              {
                                      "name" => "age",
                                      "type" => "text_field"
                              },
                              {
                                      "name" => "address",
                                      "type" => "text_field"
                              }]
              }])

      assigns[:child] = Child.new({
              "_id" => "d7ab411b5b8964b0ac178f2bc5b9b5b9",
              "basic_details" => {
                      "age" => "27",
                      "address" => "Highland Road",
                      "name" => "Tom"
              }})

      render

      response.should have_selector("#basic_details.form") do |form|
        form.should contain "Basic details"
      end
      response.should have_xpath("//div[@class='field'][1]") do |first_field|
        first_field.should contain "Tom"
      end
      response.should have_xpath("//div[@class='field'][2]") do |second_field|
        second_field.should contain "27"
      end
      response.should have_xpath("//div[@class='field'][3]") do |third_field|
        third_field.should contain "Highland Road"
      end
    end

    it "displays any fields on the record that aren't in the Schema at the end, in alphabetical order" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "basic_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "name",
                                      "type" => "text_field"
                              }]
              }])

      assigns[:child] = Child.new({
              "_id" => "d7ab411b5b8964b0ac178f2bc5b9b5b9",
              "basic_details" => {
                      "name" => "Adrian",
                      "supplementary_field" => "Supplementary field value",
                      "extra_field" => "Extra field value"
              }})

      render

      response.should have_xpath("//div[@class='field'][1]") do |first_field|
        first_field.should contain "Adrian"
      end
      response.should have_xpath("//div[@class='field'][2]") do |second_field|
        second_field.should contain "Extra field value"
      end
      response.should have_xpath("//div[@class='field'][3]") do |third_field|
        third_field.should contain "Supplementary field value"
      end

    end

    it "renders repeating text fields on a single line" do

      pending

      render :locals => { :form => {"uncle_name" => ["Tim", "Mike", "Paul"]} }

      response.should contain("Uncle names: Tim, Mike, Paul")
    end

    it "renders fields in the order they were defined on the Schema" do

      pending

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
