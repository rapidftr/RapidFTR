class SearchWidget
  include NavigationHelpers

  def initialize(session)
    @session = session
  end

  def search_for(search_term)
    @session.fill_in('query', :with => search_term)
    @session.click_button('Go')
  end

  private

end