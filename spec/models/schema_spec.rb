require 'spec_helper'

describe Schema do

  describe "keys_in_order" do

    it "returns the list of keys of schema in the order they were defined" do
      Schema.stub(:get_schema).and_return(:fields => [
              {
                      :name => "name",
                      :type => "text_field"
              },
              {
                      :name => "age",
                      :type => "text_field"
              },
              {
                      :name => "is_age_exact",
                      :type => "radio_button",
                      :options =>["exact", "approximate"]
              }])

      Schema.keys_in_order.should == ["name", "age", "is_age_exact"]

    end
  end

end
