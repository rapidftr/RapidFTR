class NewChildPage
  include NavigationHelpers
  include RSpec::Matchers

  def initialize(session)
    @session = session
  end

  def visit_page
    @session.visit path_to('new child page')
  end

  def enter_details(child_name, birthplace)
    @session.fill_in('Name', :with => child_name)
    @session.fill_in('Birthplace', :with => birthplace)
  end

  def save
    @session.click_button('Save')
  end

  def section_should_not_be_visible(section_name)
    expect(@session.has_no_link?(section_name)).to be true
  end

  def section_should_be_visible(section_name)
    expect(@session.has_link?(section_name)).to be true
  end
end
