require 'rails_generator'
require 'rails_generator/scripts/generate'
Rails::Generator::Scripts::Generate.new.run(['couchrest_rails', 'relax'], :destination => RAILS_ROOT)