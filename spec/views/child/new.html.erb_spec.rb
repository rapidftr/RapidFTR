require 'spec_helper'

class FormSection;
end

describe "children/new.html.erb" do

  describe "rendering new Child page"  do

    before :each do
      @form_section = FormSection.new "section_name"
      assigns[:form_sections] = [@form_section]
      @form_target = "/children"
    end

    it "renders a form that posts to the children url" do
      render

      response.should have_selector("form", :action => "/children" )
    end

    it "should render text fields" do

      @form_section.add_text_field("name")

      render

      @form_section.fields.each do |field|
        response.should have_selector("label[for='#{field.tag_id}']")
        response.should have_selector("input[id='#{field.tag_id}'][type='text'][name='#{field.tag_name_attribute}']")
      end
    end

    it "renders radio button fields" do
      @form_section.add_field Field.new_radio_button("is_act_exact", ["exact", "approximate"])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='exact']")
        form.should have_selector("input[name='child[is_act_exact]'][type='radio'][value='approximate']")
      end
    end

    it "render select boxes" do
      @form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than a year ago"])

      render

      response.should have_selector("form") do |form|
        form.should have_selector("label[for='child_date_of_separation']")
        form.should have_selector("select[name='child[date_of_separation]'][id='child_date_of_separation']") do |select|
          select.should have_selector("option[value='1-2 weeks ago']")
          select.should have_selector("option[value='More than a year ago']")
        end
      end

    end
  end

end
