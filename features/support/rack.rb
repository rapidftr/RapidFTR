module CapybaraApp
  def app
    Capybara.app
  end
end
World(CapybaraApp)
World(Rack::Test::Methods)
