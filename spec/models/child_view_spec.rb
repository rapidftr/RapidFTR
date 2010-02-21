require "spec"

describe "ChildView" do

  it "creates a ChildView object based on a form template" do
    template = [
            {
                    "name" => "age",
                    "type" => "text_field"
            },
            {
                    "name" => "gender",
                    "type" => "radio_button",
                    "options" => ["male", "female"]
            },
    ]
    
    child_view = ChildView.get_child_view_for_template template

    child_view.fields.size.should == 2

    text_field = child_view.fields[0]
    text_field.type.should == "text_field"
    text_field.name.should == "age"
    
    radio_button_field = child_view.fields[1]
    radio_button_field.type.should == "radio_button"
    radio_button_field.options.size.should == 2
    radio_button_field.options.first.option_name.should == "male"
  end

end

