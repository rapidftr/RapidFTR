class FormSectionPage
  include NavigationHelpers
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def should_list_the_following_sections(section_names)
    names_on_page = all(:css, "#form_sections tbody tr td a[@class='formSectionLink']").map(&:text)
    names_on_page.should == section_names
  end

  def section_should_have_description(section_name, expected_description)
    row_for(section_name).should have_xpath("//td[text()='#{expected_description}']")
  end

  def should_not_see_the_manage_fields_link
    @session.should_not have_xpath "//tr[@id=basic_details_row and contains(., 'Manage Fields')]"
  end

  def toggle_section_visibility(section_name)
    checkbox_id = form_section_visibility_checkbox_id(section_name)
    checked = find("//input[@id='#{checkbox_id}']").checked?
    if checked
      uncheck checkbox_id
    else
      check checkbox_id
    end
  end

  def create_text_field(display_name, help_text)
    @session.click_link('Add Field')
    @session.has_content?('field_display_name_en', :visible => true)
    @session.click_link('Text Field')
    @session.fill_in('field_display_name_en', :with => display_name)
    @session.fill_in('Help text', :with => help_text)
    find(:xpath, "//form[@id='new_field']//input[@value='Save Details']").click
  end

  def should_have_view_and_download_reports_section_selected
    @session.find(:xpath,"//input[@id='view_and_download_reports']").should be_checked
  end

  def cancel
    @session.click_link('Cancel')
  end

  def should_be_editing_section(section_name)
    id = FormSection.all.find { |f| f.name == section_name }.unique_id
    URI.parse(@session.current_url).path.should eq "/form_section/#{id}/edit"
  end

  def should_show_fields_in_order(expected_field_order)
    actual_order = @session.all(:xpath, "//tr[@class='rowEnabled']/td[1]").collect(&:text)
    actual_order.should == expected_field_order
  end

  def section_should_not_be_enabled(section_name)
    row_for(section_name).should_not(have_css("input[id^='sections_'][type='checkbox']"))
  end

  def section_should_be_enabled(section_name)
    row_for(section_name).should(have_css("input[id^='sections_'][type='checkbox']"))
  end

  private

  def row_for(section_name)
    @session.find row_xpath_for(section_name)
  end

  def row_xpath_for(section_name)
    "//a[@class='formSectionLink' and contains(., '#{section_name}')]/ancestor::tr"
  end

  def form_section_visibility_checkbox_id(section_name)
    "sections_#{section_name}"
  end
end