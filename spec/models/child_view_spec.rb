require "spec"

describe "FormSection" do

  it "creates a FormSection object based on a form template" do
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

    form = FormSection.create_form_section_from_template("basic_details", template)


    form.section_name.should == "basic_details"

    form.fields.size.should == 2

    text_field = form.fields[0]
    text_field.type.should == "text_field"
    text_field.name.should == "age"
    text_field.value.should == nil

    radio_button_field = form.fields[1]
    radio_button_field.type.should == "radio_button"
    radio_button_field.options.size.should == 2
    radio_button_field.options.first.option_name.should == "male"
    radio_button_field.value.should == nil
  end

  it "creates a FormSection object based on a form template and an existing Child object" do
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

    form = FormSection.create_form_section_from_template("basic_details", template, child)

    form.fields.size.should == 2

    text_field = form.fields[0]
    text_field.type.should == "text_field"
    text_field.name.should == "age"
    text_field.value.should == "27"

    radio_button_field = form.fields[1]
    radio_button_field.type.should == "radio_button"
    radio_button_field.options.size.should == 2
    radio_button_field.options.first.option_name.should == "male"
    radio_button_field.value.should == "male"

  end


end

