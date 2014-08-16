class HighlightFieldsPage
  include NavigationHelpers
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def select_menu_with_text(text_value)
    @session.find('//li', :text => text_value).click
  end

  def remove_field_with_name(field_name)
    @session.find('//td', :text => field_name).find('..').click_link('remove')
  end

  private

end