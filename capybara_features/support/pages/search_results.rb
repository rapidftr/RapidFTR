class SearchResults
  include NavigationHelpers
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def select_result(index)
    checkbox = @session.all(:xpath, "//p[@class='checkbox']//input[@type='checkbox']")[index]
    raise 'result row to select has not checkbox' if checkbox.nil?
    check(checkbox[:id])
  end

  def should_contain_result(result_text)
    match = @session.find('//div[@class="child_summary_panel"]//div[@class="summary_item"]//div[@class="value"]', :text => result_text)
    raise Spec::Expectations::ExpectationNotMetError, "#{result_text} - This value could not be found in the search results." unless match
  end

  def should_not_contain_result(result_text)
    expect { @session.find('//a', :text => result_text) }.to raise_error(Capybara::ElementNotFound)
  end

  def child_should_not_be_reunited(child_id)
    @session.assert_no_selector(:css, reunited_child_css_selector(child_id))
  end

  def child_should_be_reunited(child_id)
    @session.assert_selector(:css, reunited_child_css_selector(child_id))
  end

  private

  def reunited_child_css_selector(child_id)
    "#child_#{child_id} .summary_panel .reunited"
  end
end
