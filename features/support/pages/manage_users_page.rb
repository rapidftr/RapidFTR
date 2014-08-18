class ManageUsersPage
  include RSpec::Matchers

  def initialize(session)
    @session = session
  end

  def should_show_users_in_order(expected_user_names)
    expect(actual_user_names).to eq(expected_user_names)
  end

  private

  def actual_user_names
    @session.all(:xpath, "//td[@class='full_name']").map(&:text)
  end
end
