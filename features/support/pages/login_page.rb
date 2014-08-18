class LoginPage
  include NavigationHelpers

  def initialize(session)
    @session = session
  end

  def login_as(username, password)
    visit_page
    enter_username(username)
    enter_password(password)
    login
  end

  private

  def visit_page
    @session.visit path_to('login page')
  end

  def enter_username(username)
    @session.fill_in('User Name', :with => username)
  end

  def enter_password(password)
    @session.fill_in('Password', :with => password)
  end

  def login
    @session.click_button('Log in')
  end
end
