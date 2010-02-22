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

    child_view = ChildView.create_child_view_from_template(template)

    child_view.fields.size.should == 2

    text_field = child_view.fields[0]
    text_field.type.should == "text_field"
    text_field.name.should == "age"
    text_field.value.should == nil

    radio_button_field = child_view.fields[1]
    radio_button_field.type.should == "radio_button"
    radio_button_field.options.size.should == 2
    radio_button_field.options.first.option_name.should == "male"
    radio_button_field.value.should == nil
  end

  it "creates a ChildView object based on a form template and an existing Child object" do
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

    child = Child.new("age" => "27", "gender" => "male")

    child_view = ChildView.create_child_view_from_template(template, child)

    child_view.fields.size.should == 2

    text_field = child_view.fields[0]
    text_field.type.should == "text_field"
    text_field.name.should == "age"
    text_field.value.should == "27"

    radio_button_field = child_view.fields[1]
    radio_button_field.type.should == "radio_button"
    radio_button_field.options.size.should == 2
    radio_button_field.options.first.option_name.should == "male"
    radio_button_field.value.should == "male"

  end


  it 'should set the unique id on the child view object' do
    template = []
    child = Child.new("unique_identifier" => "some id")
    child_view = ChildView.create_child_view_from_template(template, child)
    child_view.unique_id.should == 'some id'
  end

end

