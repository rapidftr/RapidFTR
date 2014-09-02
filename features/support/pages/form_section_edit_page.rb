class FormSectionEditPage
  include NavigationHelpers
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def should_not_be_able_to_edit_field(field_name)
    expect(@session).not_to have_selector(:xpath, field_selector(field_name))
  end

  def should_be_able_to_edit_field(field_name)
    expect(@session).to have_selector(:xpath, field_selector(field_name))
  end

  def mark_nationality_field_as_hidden
    check('fields_nationality')
  end

  def mark_field_as_matchable(field_name)
    check("fields_#{field_name}")
  end

  private

  def field_selector(field_name)
    "//td[text()=\"#{field_name}\"]/parent::*/td/div/select"
  end
end
