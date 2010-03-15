require 'spec_helper'

class FormSection;
end

describe "children/_form_section.html.erb" do

  describe "rendering a form section for existing data" do

    before :each do
      @form_section = FormSection.new
      @form_target = "form_target"
    end

    it "should show a text field box with the existing value prepopulated" do

      @form_section.add_field(Field.new("name", Field::TEXT_FIELD, [], "Jessica"))

      render :locals => { :form_section => @form_section }

      response.should have_selector("input[id='child_name'][type='text'][name='child[name]'][value='Jessica']")
    end

    it "should show a radio button with the existing value selected" do
      @form_section.add_field Field.new("is_act_exact", Field::RADIO_BUTTON, ["exact", "approximate"], "approximate")

      render :locals => { :form_section => @form_section }

      response.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='exact']")
      response.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='approximate'][checked]")
    end

    it "should show a select box with the existing value selected" do
      @form_section.add_field Field.new("date_of_separation", Field::SELECT_BOX, ["1-2 weeks ago", "More than a year ago"], "1-2 weeks ago")

      render :locals => { :form_section => @form_section }

      response.should have_selector("select[name='child[date_of_separation]'][id='child_date_of_separation']") do |select|
        select.should have_selector("option[value='1-2 weeks ago'][selected]")
        select.should have_selector("option[value='More than a year ago']")
      end
    end

  end

  describe "rendering a form for blank data"  do

    before :each do
      @form_section = FormSection.new
      assigns[:form_section] = @form_section
    end

    it "should render text fields" do

      @form_section.add_text_field("name")

      render :locals => { :form_section => @form_section }

      @form_section.fields.each do |field|
        response.should have_selector("label[for='#{field.tag_id}']")
        response.should have_selector("input[id='#{field.tag_id}'][type='text'][name='#{field.tag_name_attribute}']")
      end
    end

    it "renders radio button fields" do
      @form_section.add_field Field.new_radio_button("is_act_exact", ["exact", "approximate"])

      render :locals => { :form_section => @form_section }

      response.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='exact']")
      response.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='approximate']")
    end

    it "render select boxes" do
      @form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than a year ago"])

      render :locals => { :form_section => @form_section }

      response.should have_selector("label[for='child_date_of_separation']")
      response.should have_selector("select[name='child[date_of_separation]'][id='child_date_of_separation']") do |select|
        select.should have_selector("option[value='1-2 weeks ago']")
        select.should have_selector("option[value='More than a year ago']")
      end

    end

  end

end
