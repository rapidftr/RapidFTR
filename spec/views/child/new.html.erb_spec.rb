require 'spec_helper'

class Schema;
end

describe "children/new.html.erb" do

  describe "rendering new Child record form"  do

    it "always outputs a form with a photo upload field" do
      Schema.stub(:get_schema).and_return([])

      render

      response.should have_selector("form", :method => "post", :enctype => "multipart/form-data") do |form|
        form.should have_selector("input[type='file'][name='child[photo]']")
      end

    end

    it "renders text fields" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "basic_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "age",
                                      "type" => "text_field"
                              },
                              {
                                      "name" => "last_known_location",
                                      "type" => "text_field"
                              }]
              }])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("label[for='child_basic_details_last_known_location']")
        form.should have_selector("input[id='child_basic_details_last_known_location'][type='text']")
        form.should have_selector("label[for='child_basic_details_age']")
        form.should have_selector("input[id='child_basic_details_age'][type='text']")
      end
    end

    it "renders repeating text fields, with a button for adding another one" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "family_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "uncle_name",
                                      "type" => "repeatable_text_field"
                              }]
              }])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("label[for^='child_family_details_uncle_name']") do |label|
          label.should contain "Uncle name"
        end
        form.should have_selector("input[name='child[family_details][uncle_name][]'][type='text']")
        form.should have_selector("button") do |button|
          button.should contain "Add another"
        end

      end
    end

    it "renders radio button fields" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "basic_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "is_act_exact",
                                      "type" => "radio_button",
                                      "options" => ["exact", "approximate"]
                              }]
              }])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("input[name='child[basic_details][is_act_exact]'][type='radio'][value='Exact']")
        form.should have_selector("input[name='child[basic_details][is_act_exact]'][type='radio'][value='Approximate']")
      end

    end

    it "renders select boxes" do
      Schema.stub(:get_schema).and_return(
              [{
                      "name" => "basic_details",
                      "type" => "form",
                      "fields" => [
                              {
                                      "name" => "date_of_separation",
                                      "type" => "select_box",
                                      "options" => ["1-2 weeks ago", "More than 1 year ago"]
                              }]}
              ])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("label[for='child_basic_details_date_of_separation']")
        form.should have_selector("select[name='child[basic_details][date_of_separation]'][id='child_basic_details_date_of_separation']") do |select|
          select.should have_selector("option[value='1-2 weeks ago']")
          select.should have_selector("option[value='More than 1 year ago']")
        end
      end
    end

  end

end
