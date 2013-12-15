require 'spec_helper'

describe "children/_form_section.html.erb" do

  before :each do
    @form_section = FormSection.new "unique_id" => "translated", "name" => "displayed_form_name"
  end

  describe "translating form section name" do
    it "should be shown with translated name" do
      translated_name = "translated_form_name"
      I18n.locale = :fr
      I18n.backend.store_translations("fr", @form_section.unique_id => translated_name)
      render :partial => 'children/tabs' , :object => [@form_section], :formats => [:html], :handlers => [:erb]
      rendered.should be_include(translated_name)
      rendered.should_not be_include(@form_section.name)
    end
    it "should not be shown with translated name" do
      I18n.backend.store_translations("fr", @form_section.unique_id => nil)
      render :partial => 'children/tabs', :object => [@form_section], :formats => [:html], :handlers => [:erb]
      rendered.should be_include(@form_section.name)
    end
  end

  describe "translating form section heading" do
    it "should be shown with translated heading" do
      translated_name = "translated_heading"
      I18n.locale = :fr
      I18n.backend.store_translations("fr", @form_section.unique_id => translated_name)
      @form_sections = [ @form_section ]

      render :partial => 'children/show_form_section', :formats => [:html], :handlers => [:erb]

      rendered.should be_include(translated_name)
      rendered.should_not be_include(@form_section.name)
    end

      it "should not be shown with translated heading" do
        I18n.backend.store_translations("fr", @form_section.unique_id => nil)
        @form_sections = [ @form_section ]
        render :partial => 'children/show_form_section', :formats => [:html], :handlers => [:erb]
      end
  end

  describe "rendering text fields" do

    context "new record" do

      it "renders text fields with a corresponding label" do
        field = Field.new_field("text_field", "name")
        @form_section.add_field(field)

        @child = Child.new
        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        @form_section.fields.each do |field|
          rendered.should be_include("<label class=\"key\" for=\"#{field.tag_id}\">")
          rendered.should be_include("<input id=\"#{field.tag_id}\" name=\"#{field.tag_name_attribute}\" type=\"text\" />")
        end
      end
    end

    context "existing record" do

      it "prepopulates the text field with the existing value" do
        @child = Child.new :name => "Jessica"
        @form_section.add_field(Field.new_field("text_field", "name"))

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        rendered.should be_include("<input id=\"child_name\" name=\"child[name]\" type=\"text\" value=\"Jessica\" />")
      end
    end
  end

  describe "rendering radio buttons" do

    context "new record" do

      it "renders radio button fields" do
        @child = Child.new
        @form_section.add_field Field.new_field("radio_button", "is_age_exact", ["exact", "approximate"])

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        rendered.should be_include("<input id=\"child_isageexact_exact\" name=\"child[isageexact]\" type=\"radio\" value=\"exact\" />")
        rendered.should be_include("<input id=\"child_isageexact_approximate\" name=\"child[isageexact]\" type=\"radio\" value=\"approximate\" />")
      end
    end

    context "existing record" do

      it "renders a radio button with the current option selected" do
        @child = Child.new :isageexact => "approximate"

        @form_section.add_field Field.new_field("radio_button", "is_age_exact", ["exact", "approximate"])

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        rendered.should be_include("<input id=\"child_isageexact_exact\" name=\"child[isageexact]\" type=\"radio\" value=\"exact\" />")
        rendered.should be_include("<input checked=\"checked\" id=\"child_isageexact_approximate\" name=\"child[isageexact]\" type=\"radio\" value=\"approximate\" />")
      end
    end
  end

  describe "rendering select boxes" do

    context "new record" do

      it "render select boxes" do
        @child = Child.new
        @form_section.add_field Field.new_field("select_box", "date_of_separation", ["1-2 weeks ago", "More than a year ago"])

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        rendered.should be_include("<label class=\"key\" for=\"child_dateofseparation\">")
        rendered.should be_include("<select id=\"child_dateofseparation\" name=\"child[dateofseparation]\"><option value=\"\" selected=\"selected\">(Select...)</option>\n<option value=\"1-2 weeks ago\">1-2 weeks ago</option>\n<option value=\"More than a year ago\">More than a year ago</option></select>")
      end
    end
  end

  context "existing record" do

    it "renders a select box with the current value selected" do
      @child = Child.new :date_of_separation => "1-2 weeks ago"
      @form_section.add_field Field.new_field("select_box","date_of_separation", ["1-2 weeks ago", "More than a year ago"])

      render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

      rendered.should be_include("<select id=\"child_dateofseparation\" name=\"child[dateofseparation]\"><option value=\"\" selected=\"selected\">(Select...)</option>\n<option value=\"1-2 weeks ago\">1-2 weeks ago</option>\n<option value=\"More than a year ago\">More than a year ago</option></select>")
    end
  end

  describe "rendering check boxes" do

    context "existing record" do

      it "renders checkboxes as checked if the underlying field is set to Yes" do
        @child = Child.new :relatives => ["Brother", "Sister"]
        @form_section.add_field Field.new_field("check_boxes", "relatives", ["Sister", "Brother", "Cousin"])

        render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]

        rendered.should be_include("<input checked=\"checked\" id=\"child_relatives_sister\" name=\"child[relatives][]\" type=\"checkbox\" value=\"Sister\" />")
        rendered.should be_include("<input checked=\"checked\" id=\"child_relatives_sister\" name=\"child[relatives][]\" type=\"checkbox\" value=\"Sister\" />")
      end

    end
  end

  #TODO Date picker must be implemented in Advanced Search Page

  #describe "rendering date field" do

    #context "new record" do
    #  it "renders date field" do
    #    @child = Child.new
    #    @form_section.add_field Field.new_field("date_field", "Some date")
    #
    #    render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]
    #    rendered.should be_include("label for=\"child_some_date\"")
    #    rendered.should be_include("<input id=\"child_some_date\" name=\"child[some_date]\" type=\"text\" />")
    #    rendered.should be_include("<script type=\"text/javascript\">\n//<![CDATA[\n$(document).ready(function(){ $(\"#child_some_date\").datepicker({ dateFormat: 'dd M yy' }); });\n//]]>\n</script>")
    #  end
    #end
    #
    #context "existing record" do
    #
    #  it "renders date field with the previous date" do
    #    @child = Child.new :some_date => "13/05/2004"
    #    @form_section.add_field Field.new_field("date_field", "Some date")
    #
    #    render :partial => 'children/form_section', :locals => { :form_section => @form_section }, :formats => [:html], :handlers => [:erb]
    #
    #
    #    rendered.should be_include("<input id=\"child_some_date\" name=\"child[some_date]\" type=\"text\" value=\"13/05/2004\" />")
    #    rendered.should be_include("<script type=\"text/javascript\">\n//<![CDATA[\n$(document).ready(function(){ $(\"#child_some_date\").datepicker({ dateFormat: 'dd M yy' }); });\n//]]>\n</script")
    #  end
    #
    #end
  #end

end
