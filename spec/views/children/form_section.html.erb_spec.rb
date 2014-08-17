require 'spec_helper'

describe "children/_form_section.html.erb", :type => :view do

  before :each do
    @form_section = FormSection.new "unique_id" => "translated", "name" => "displayed_form_name"
  end

  describe "translating form section name" do
    it "should be shown with translated name" do
      translated_name = "translated_form_name"
      I18n.locale = :fr
      I18n.backend.store_translations("fr", @form_section.unique_id => translated_name)
      render :partial => 'children/tabs', :object => [@form_section], :formats => [:html], :handlers => [:erb]
      expect(rendered).to be_include(translated_name)
      expect(rendered).not_to be_include(@form_section.name)
    end
    it "should not be shown with translated name" do
      I18n.backend.store_translations("fr", @form_section.unique_id => nil)
      render :partial => 'children/tabs', :object => [@form_section], :formats => [:html], :handlers => [:erb]
      expect(rendered).to be_include(@form_section.name)
    end
  end

  describe "translating form section heading" do
    it "should be shown with translated heading" do
      translated_name = "translated_heading"
      I18n.locale = :fr
      I18n.backend.store_translations("fr", @form_section.unique_id => translated_name)
      @form_sections = [@form_section]

      render :partial => 'children/show_form_section', :formats => [:html], :handlers => [:erb]

      expect(rendered).to be_include(translated_name)
      expect(rendered).not_to be_include(@form_section.name)
    end

    it "should not be shown with translated heading" do
      I18n.backend.store_translations("fr", @form_section.unique_id => nil)
      @form_sections = [@form_section]
      render :partial => 'children/show_form_section', :formats => [:html], :handlers => [:erb]
    end
  end

  describe "rendering text fields" do

    context "new record" do

      it "renders text fields with a corresponding label" do
        field = build :text_field
        @form_section.add_field(field)

        @child = Child.new
        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        @form_section.fields.each do |field|
          expect(rendered).to be_include("<label class=\"key\" for=\"#{field.tag_id}\">")
          expect(rendered).to be_include("<input id=\"#{field.tag_id}\" name=\"#{field.tag_name_attribute}\" type=\"text\" />")
        end
      end
    end

    context "existing record" do

      it "prepopulates the text field with the existing value" do
        @child = Child.new :name => "Jessica"
        @form_section.add_field build(:text_field, :name => 'name')

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        expect(rendered).to be_include("<input id=\"child_name\" name=\"child[name]\" type=\"text\" value=\"Jessica\" />")
      end
    end
  end

  describe "rendering radio buttons" do

    context "new record" do

      it "renders radio button fields" do
        @child = Child.new
        @form_section.add_field build(:radio_button_field, :name => 'is_age_exact', :option_strings => %w(exact approximate))

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        expect(rendered).to be_include("<input id=\"child_is_age_exact_exact\" name=\"child[is_age_exact]\" type=\"radio\" value=\"exact\" />")
        expect(rendered).to be_include("<input id=\"child_is_age_exact_approximate\" name=\"child[is_age_exact]\" type=\"radio\" value=\"approximate\" />")
      end
    end

    context "existing record" do

      it "renders a radio button with the current option selected" do
        @child = Child.new :is_age_exact => "approximate"

        @form_section.add_field build(:radio_button_field, :name => 'is_age_exact', :option_strings => %w(exact approximate))

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        expect(rendered).to be_include("<input id=\"child_is_age_exact_exact\" name=\"child[is_age_exact]\" type=\"radio\" value=\"exact\" />")
        expect(rendered).to be_include("<input checked=\"checked\" id=\"child_is_age_exact_approximate\" name=\"child[is_age_exact]\" type=\"radio\" value=\"approximate\" />")
      end
    end
  end

  describe "rendering select boxes" do

    context "new record" do

      it "render select boxes" do
        @child = Child.new
        @form_section.add_field build(:select_box_field, :name => 'date_of_separation', :option_strings => ["1-2 weeks ago", "More than a year ago"])

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        expect(rendered).to be_include("<label class=\"key\" for=\"child_date_of_separation\">")
        expect(rendered).to be_include("<select id=\"child_date_of_separation\" name=\"child[date_of_separation]\"><option selected=\"selected\" value=\"\">(Select...)</option>\n<option value=\"1-2 weeks ago\">1-2 weeks ago</option>\n<option value=\"More than a year ago\">More than a year ago</option></select>")
      end
    end
  end

  context "existing record" do

    it "renders a select box with the current value selected" do
      @child = Child.new :date_of_separation => "1-2 weeks ago"
      @form_section.add_field build(:select_box_field, :name => 'date_of_separation', :option_strings => ["1-2 weeks ago", "More than a year ago"])

      render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

      expect(rendered).to have_tag 'select[id="child_date_of_separation"][name="child[date_of_separation]"]' do
        with_tag 'option[value=""]', :text => '(Select...)'
        with_tag 'option[value="1-2 weeks ago"][selected="true"]', :text => '1-2 weeks ago'
        with_tag 'option[value="More than a year ago"]', :text => 'More than a year ago'
      end
    end
  end

  describe "rendering check boxes" do

    context "existing record" do

      it "renders checkboxes as checked if the underlying field is set to Yes" do
        @child = Child.new :relatives => %w(Brother Sister)
        @form_section.add_field build(:check_boxes_field, :name => 'relatives', :option_strings => %w(Sister Brother Cousin))

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        expect(rendered).to have_tag 'input[checked="checked"][id="child_relatives_sister"][name="child[relatives][]"][type="checkbox"][value="Sister"]'
        expect(rendered).to have_tag 'input[checked="checked"][id="child_relatives_brother"][name="child[relatives][]"][type="checkbox"][value="Brother"]'
      end

    end
  end

  # TODO Date picker must be implemented in Advanced Search Page

  # describe "rendering date field" do

  # context "new record" do
  #  it "renders date field" do
  #    @child = Child.new
  #    @form_section.add_field build(:date_field, name: 'some_date')
  #
  #    render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]
  #    rendered.should be_include("label for=\"child_some_date\"")
  #    rendered.should be_include("<input id=\"child_some_date\" name=\"child[some_date]\" type=\"text\" />")
  #    rendered.should be_include("<script type=\"text/javascript\">\n//<![CDATA[\n$(document).ready(function(){ $(\"#child_some_date\").datepicker({ dateFormat: 'dd M yy' }); });\n//]]>\n</script>")
  #  end
  # end
  #
  # context "existing record" do
  #
  #  it "renders date field with the previous date" do
  #    @child = Child.new :some_date => "13/05/2004"
  #    @form_section.add_field build(:date_field, name: 'some_date')
  #
  #    render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]
  #
  #
  #    rendered.should be_include("<input id=\"child_some_date\" name=\"child[some_date]\" type=\"text\" value=\"13/05/2004\" />")
  #    rendered.should be_include("<script type=\"text/javascript\">\n//<![CDATA[\n$(document).ready(function(){ $(\"#child_some_date\").datepicker({ dateFormat: 'dd M yy' }); });\n//]]>\n</script")
  #  end
  #
  # end
  # end

end
