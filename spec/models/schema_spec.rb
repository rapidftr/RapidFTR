require 'spec_helper'

describe Schema do

  describe "Field ordering" do

    it "returns the list of field names for a given form in the order they are defined" do
      Schema.stub(:get_schema).and_return(
              [
                      {       "name" => "basic_details",
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
                                              "name" => "is_age_exact",
                                              "type" => "radio_button",
                                              "options" =>["exact", "approximate"]
                                      }]
                      }])

      Schema.fields_in_order_for_form("basic_details").should == ["name", "age", "is_age_exact"]
    end
  end

  it "reorders a list of record fields according to their order on the Schema" do

    Schema.stub(:get_schema).and_return(
              [
                      {       "name" => "basic_details",
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
                                              "name" => "is_age_exact",
                                              "type" => "radio_button",
                                              "options" =>["exact", "approximate"]
                                      }]
                      }])

      Schema.order_fields_according_to_form(["age", "name", "birthday"], "basic_details").should == ["name", "age", "birthday"]

  end


end
