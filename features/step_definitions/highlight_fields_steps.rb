Given /^I select menu "(.+)"$/ do |text_value|
  highlight_fields_page.select_menu_with_text(text_value)
end

And /^I remove highlight "(.+)"$/ do |field_name|
  highlight_fields_page.remove_field_with_name(field_name)
end

private

def highlight_fields_page
  @_highlight_fields_page ||= HighlightFieldsPage.new(Capybara.current_session)
end