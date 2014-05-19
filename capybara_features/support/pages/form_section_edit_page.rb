class FormSectionEditPage
  include NavigationHelpers
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def should_not_be_able_to_edit_field(field_name)
    @session.should_not(have_selector(:xpath, field_selector(field_name)))
  end

  def should_be_able_to_edit_field(field_name)
    @session.should(have_selector(:xpath, field_selector(field_name)))
  end

  private

  def field_selector(field_name)
    "//td[text()=\"#{field_name}\"]/parent::*/td/div/select"
  end
end