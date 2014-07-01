namespace :cane do
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 144

    #TODO: clean up whitespaces and long lines of code
    cane.no_style = true
    #cane.no_style = false
    #cane.style_measure = 110 #max line length

    cane.no_doc = true

    cane.max_violations = 20
  end

end
