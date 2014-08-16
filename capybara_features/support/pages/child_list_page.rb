class ChildListPage
  include RSpec::Matchers
  include Capybara::DSL

  def initialize(session)
    @session = session
  end

  def should_not_be_paged
    expect(@session).to have_no_selector(:css, 'nav.pagination')
  end

  def should_be_showing_first_page
    expect(@session).to have_selector(:css, PAGINATION_SELECTOR)
    expect(@session).to have_selector(:css, NEXT_PAGE_LINK_SELECTOR)
    expect(@session).to have_selector(:css, PREV_PAGE_DISABLED_LINK_SELECTOR)
    expect(@session.find(:css, CURRENT_PAGE_INDICATOR_SELECTOR)).to have_content('1')
  end

  def should_be_showing_last_page
    expect(@session).to have_selector(:css, PAGINATION_SELECTOR)
    expect(@session).to have_selector(:css, PREV_PAGE_LINK_SELECTOR)
    expect(@session).to have_selector(:css, NEXT_PAGE_DISABLED_LINK_SELECTOR)
    expect(@session.find(:css, CURRENT_PAGE_INDICATOR_SELECTOR)).to have_content('2')
  end

  def should_be_showing(child_count)
    expect(@session.all(:css, CHILD_SUMMARY_PANEL_SELECTOR).count).to eq child_count
  end

  def should_be_on_page(page_number)
    expect(page.find(:css, CURRENT_PAGE_INDICATOR_SELECTOR)).to have_content(page_number)
  end

  def go_to_page(page_number)
    page.find(:css, PAGINATION_SELECTOR).click_link(page_number)
  end

  def sort(sort_order)
    case sort_order
      when 'ascending'
        page.find(:css, "li#sort_ascending_arrow").click
      when 'descending'
        page.find(:css, "li#sort_descending_arrow").click
    end
  end

  private
  PAGINATION_SELECTOR = 'div.pagination'
  PREV_PAGE_LINK_SELECTOR =  "#{PAGINATION_SELECTOR} a.previous_page"
  NEXT_PAGE_LINK_SELECTOR = "#{PAGINATION_SELECTOR} a.next_page"
  PREV_PAGE_DISABLED_LINK_SELECTOR = "#{PAGINATION_SELECTOR} span.previous_page"
  NEXT_PAGE_DISABLED_LINK_SELECTOR = "#{PAGINATION_SELECTOR} span.next_page"
  CURRENT_PAGE_INDICATOR_SELECTOR = "#{PAGINATION_SELECTOR} em.current"
  CHILD_SUMMARY_PANEL_SELECTOR = '.child_summary_panel'
end
