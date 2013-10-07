class SearchResults
  include NavigationHelpers
  include RSpec::Matchers

  def initialize(session)
    @session = session
  end

  def should_contain_result(result_text)
    match = @session.find('//a', :text => result_text)
    raise Spec::Expectations::ExpectationNotMetError, "#{result_text} - This value could not be found in the search results." unless match
  end

  def child_should_not_be_reunited(child_id)
    @session.should_not have_xpath "//div[@id='#{child_id}']/div/img[@class='reunited']"
  end

private
end
