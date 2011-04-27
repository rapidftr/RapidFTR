require 'spec_helper'

class FormSection;
end

describe "children/_form_section.html.erb" do

  before :each do
    @form_section = FormSection.new "unique_id" => "section_name"
  end

  describe "rendering text fields" do

    context "new record" do

      it "renders text fields with a corresponding label" do
        field = Field.new_field("text_field", "name")
        @form_section.add_field(field)

        assigns[:child] = Child.new
        render :locals => { :form_section => @form_section }

        @form_section.fields.each do |field|
          response.should have_tag("label[for='#{field.tag_id}']")
          response.should have_tag("input[id='#{field.tag_id}'][type='text'][name='#{field.tag_name_attribute}']")
        end
      end
    end

    context "existing record" do

      it "prepopulates the text field with the existing value" do
        @child = Child.new :name => "Jessica"
        @form_section.add_field(Field.new_field("text_field", "name"))

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input#child_name", :value => "Jessica")
      end
    end
  end

  describe "rendering radio buttons" do

    context "new record" do

      it "renders radio button fields" do
        @child = Child.new
        @form_section.add_field Field.new_field("radio_button", "is_age_exact", ["exact", "approximate"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input[name='child[isageexact]'][type='radio'][value='exact']")
        response.should have_tag("input[name='child[isageexact]'][type='radio'][value='approximate']")
      end
    end

    context "existing record" do

      it "renders a radio button with the current option selected" do
        @child = Child.new :isageexact => "approximate"

        @form_section.add_field Field.new_field("radio_button", "is_age_exact", ["exact", "approximate"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input[name='child[isageexact]'][type='radio'][value='exact']")
        response.should have_tag("input[name='child[isageexact]'][type='radio'][value='approximate'][checked]")
      end
    end
  end

  describe "rendering select boxes" do

    context "new record" do

      it "render select boxes" do
        @child = Child.new
        @form_section.add_field Field.new_field("select_box", "date_of_separation", ["1-2 weeks ago", "More than a year ago"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("label[for='child_dateofseparation']")
        response.should have_tag("select[name='child[dateofseparation]'][id='child_dateofseparation']") do |select|
          select.should have_tag("option[value='1-2 weeks ago']")
          select.should have_tag("option[value='More than a year ago']")
        end
      end
    end
  end

  context "existing record" do

    it "renders a select box with the current value selected" do
      @child = Child.new :date_of_separation => "1-2 weeks ago"
      @form_section.add_field Field.new_field("select_box","date_of_separation", ["1-2 weeks ago", "More than a year ago"])

      assigns[:child] = @child
      render :locals => { :form_section => @form_section }

      response.should have_tag("select[name='child[dateofseparation]'][id='child_dateofseparation']") do |select|
        select.should have_tag("option[value='1-2 weeks ago']")
        select.should have_tag("option[value='More than a year ago']")
      end
    end
  end

  describe "rendering check boxes" do

    context "new record" do

      it "renders checkboxes" do
        @child = Child.new
        @form_section.add_field Field.new_field("check_box", "is_orphan")

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("label[for='child_isorphan']")
        response.should have_tag("input[type='checkbox'][name='child[isorphan]'][value='Yes']")
      end
    end

    context "existing record" do

      it "renders checkboxes as checked if the underlying field is set to Yes" do
        @child = Child.new :isorphan => "Yes"
        @form_section.add_field Field.new_field("check_box", "isorphan")

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input[type='checkbox'][name='child[isorphan]'][value='Yes'][checked]")
      end

      it "renders checkboxes with the HTML FORM hidden field workaround for unchecking a property" do
        @child = Child.new :is_orphan => "Yes"
        @form_section.add_field Field.new_field("check_box", "isorphan")

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input[type='hidden'][name='child[isorphan]'][value='No']")
      end

    end
  end

  describe "rendering date field" do

    context "new record" do
      it "renders date field" do
        @child = Child.new
        @form_section.add_field Field.new_field("date_field", "Some date")

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("label[for='child_some_date']")
        response.should have_tag("input[type='text'][name='child[some_date]']")
        response.should have_tag("script[type='text/javascript']", /.*\$\("#child_some_date"\).datepicker.*/)
      end
    end

    context "existing record" do

      it "renders date field with the previous date" do
        @child = Child.new :some_date => "13/05/2004"
        @form_section.add_field Field.new_field("date_field", "Some date")

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_tag("input[type='text'][name='child[some_date]'][value='13/05/2004']")
        response.should have_tag("script[type='text/javascript']", /.*\$\("#child_some_date"\).datepicker.*/)
      end

    end
  end

end
