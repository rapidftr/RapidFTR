require 'spec_helper'

class FormSection;
end

describe "children/_form_section.html.erb" do

  before :each do
    @form_section = FormSection.new
  end

  describe "rendering text fields" do

    context "new record" do

      it "renders text fields with a corresponding label" do
        @form_section.add_text_field("name")

        assigns[:child] = Child.new
        render :locals => { :form_section => @form_section }

        @form_section.fields.each do |field|
          response.should have_selector("label[for='#{field.tag_id}']")
          response.should have_selector("input[id='#{field.tag_id}'][type='text'][name='#{field.tag_name_attribute}']")
        end
      end
    end

    context "existing record" do

      it "prepopulates the text field with the existing value" do
        @child = Child.new :name => "Jessica"
        @form_section.add_field(Field.new("name", Field::TEXT_FIELD, []))

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("input#child_name", :value => "Jessica")
      end
    end
  end

  describe "rendering radio buttons" do

    context "new record" do

      it "renders radio button fields" do
        @child = Child.new
        @form_section.add_field Field.new_radio_button("is_age_exact", ["exact", "approximate"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("input[name='child[is_age_exact]'][type='radio'][value='exact']")
        response.should have_selector("input[name='child[is_age_exact]'][type='radio'][value='approximate']")
      end
    end

    context "existing record" do

      it "renders a radio button with the current option selected" do
        @child = Child.new :is_age_exact => "approximate"
        @form_section.add_field Field.new("is_age_exact", Field::RADIO_BUTTON, ["exact", "approximate"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("input[name='child[is_age_exact]'][type='radio'][value='exact']")
        response.should have_selector("input[name='child[is_age_exact]'][type='radio'][value='approximate'][checked]")
      end
    end
  end

  describe "rendering select boxes" do

    context "new record" do

      it "render select boxes" do
        @child = Child.new
        @form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than a year ago"])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("label[for='child_date_of_separation']")
        response.should have_selector("select[name='child[date_of_separation]'][id='child_date_of_separation']") do |select|
          select.should have_selector("option[value='1-2 weeks ago']")
          select.should have_selector("option[value='More than a year ago']")
        end
      end
    end
  end

  context "existing record" do

    it "renders a select box with the current value selected" do
      @child = Child.new :date_of_separation => "1-2 weeks ago"
      @form_section.add_field Field.new("date_of_separation", Field::SELECT_BOX, ["1-2 weeks ago", "More than a year ago"])

      assigns[:child] = @child
      render :locals => { :form_section => @form_section }

      response.should have_selector("select[name='child[date_of_separation]'][id='child_date_of_separation']") do |select|
        select.should have_selector("option[value='1-2 weeks ago'][selected]")
        select.should have_selector("option[value='More than a year ago']")
      end
    end
  end

  describe "rendering check boxes" do

    context "new record" do

      it "renders checkboxes" do
        @child = Child.new 
        @form_section.add_field Field.new("is_orphan", Field::CHECK_BOX)

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("label[for='child_is_orphan']")
        response.should have_selector("input[type='checkbox'][name='child[is_orphan]'][value='Yes']")
      end
    end

    context "existing record" do

      it "renders checkboxes as checked if the underlying field is set to Yes" do
        @child = Child.new :is_orphan => "Yes"
        @form_section.add_field Field.new("is_orphan", Field::CHECK_BOX, [])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("input[type='checkbox'][name='child[is_orphan]'][value='Yes'][checked]")
      end

      it "renders checkboxes with the HTML FORM hidden field workaround for unchecking a property" do
        @child = Child.new :is_orphan => "Yes"
        @form_section.add_field Field.new("is_orphan", Field::CHECK_BOX, [])

        assigns[:child] = @child
        render :locals => { :form_section => @form_section }

        response.should have_selector("input[type='hidden'][name='child[is_orphan]'][value='No']")
      end

    end
  end
end